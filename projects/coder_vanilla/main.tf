terraform {
  required_providers {
    coder = {
      source = "coder/coder"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "coder" {}

# Uses the in-cluster service account since Coder is running inside Minikube
provider "kubernetes" {}

data "coder_provisioner" "me" {}
data "coder_workspace" "me" {}

# The Coder agent runs inside the workspace to handle setup and connections
resource "coder_agent" "main" {
  os             = "linux"
  arch           = data.coder_provisioner.me.arch
  
  # This script runs automatically when the developer clicks "Create" or "Start"
  startup_script = <<-EOT
    #!/bin/bash
    set -e
    export DEBIAN_FRONTEND=noninteractive

    # 1. Install standard tools, desktop environment, and VNC server
    if ! command -v vncserver &> /dev/null; then
      echo "Installing Ubuntu Desktop UI (XFCE) and TigerVNC..."
      apt-get update -y
      apt-get install -y xfce4 xfce4-goodies tigervnc-standalone-server dbus-x11
    fi

    # 2. Configure VNC server password (default: 'coder')
    mkdir -p ~/.vnc
    echo "coder" | vncpasswd -f > ~/.vnc/passwd
    chmod 600 ~/.vnc/passwd

    # 3. Create the X startup script for the desktop
    cat <<EOF > ~/.vnc/xstartup
    #!/bin/sh
    unset SESSION_MANAGER
    unset DBUS_SESSION_BUS_ADDRESS
    exec startxfce4
    EOF
    chmod +x ~/.vnc/xstartup

    # 4. Start VNC on port 5901 (Display :1)
    vncserver -kill :1 2>/dev/null || true
    vncserver :1 -geometry 1920x1080 -depth 24 -localhost no
  EOT

  # This metadata block displays the connection instructions directly on the Coder dashboard
  metadata {
    display_name = "VNC Port Forwarding Command"
    key          = "Command"
    value        = "coder port-forward ${data.coder_workspace.me.name} 5901:5901"
  }
  metadata {
    display_name = "VNC Password"
    key          = "Password"
    value        = "coder"
  }
}

# Persistent volume so developers don't lose their files when the workspace stops
resource "kubernetes_persistent_volume_claim" "home" {
  count = data.coder_workspace.me.start_count == 1 ? 1 : 0
  metadata {
    name      = "coder-\${lower(data.coder_workspace.me.owner)}-\${lower(data.coder_workspace.me.name)}-home"
    namespace = "coder" # Aligns with your installation namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}

# The actual Kubernetes Pod provisioning the Ubuntu 24.04 environment
resource "kubernetes_pod" "main" {
  count = data.coder_workspace.me.start_count
  metadata {
    name      = "coder-\${lower(data.coder_workspace.me.owner)}-\${lower(data.coder_workspace.me.name)}"
    namespace = "coder"
  }
  spec {
    # Init container injects the Coder agent binary into the raw Ubuntu image
    init_container {
      name    = "coder-init"
      image   = "codercom/coder:latest"
      command = ["/bin/sh", "-c"]
      args    = ["cp /bin/coder /opt/coder-agent"]
      volume_mount {
        name       = "coder-agent-vol"
        mount_path = "/opt"
      }
    }

    container {
      name    = "ubuntu-24-vnc"
      image   = "ubuntu:24.04"
      
      # We install ca-certificates and curl first so the agent can talk securely to coder.xxx
      command = ["/bin/sh", "-c"]
      args    = [
        "apt-get update && apt-get install -y ca-certificates curl && /opt/coder-agent agent"
      ]
      
      env {
        name  = "CODER_AGENT_TOKEN"
        value = coder_agent.main.token
      }
      
      volume_mount {
        name       = "coder-agent-vol"
        mount_path = "/opt"
      }
      volume_mount {
        name       = "home-dir"
        mount_path = "/root"
      }
    }

    volume {
      name = "coder-agent-vol"
      empty_dir {}
    }

    volume {
      name = "home-dir"
      persistent_volume_claim {
        claim_name = kubernetes_persistent_volume_claim.home[0].metadata.name
      }
    }
  }
}
