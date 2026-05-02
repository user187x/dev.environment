#!/bin/bash

#minikube start

#echo "Navigate to directory live/dev/"
#cd live/dev

echo
cat << EOF
  Action        Command                     What happens locally?
------------------------------------------------------------------------------------
* Initialize	terragrunt init             Terragrunt downloads the local provider.
* Plan          terragrunt plan             Terraform shows you it wants to create a file.
* Apply         terragrunt apply            The Magic: A .txt file appears in your folder!
* Verify        ls ../../modules/mock_aws/  You’ll see bucket-my-test-bucket-123.txt.
* Destroy       terragrunt destroy          The .txt file is deleted automatically.
EOF
echo
