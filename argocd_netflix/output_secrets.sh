# #!/bin/bash

# # Extract arguments
# WORKER_NODE_IP="$WORKER_NODE_IP"
# BASTION_HOST="$BASTION_HOST"

# # Define variables
# WORKER_NODE_USERNAME="ec2-user"
# BASTION_USERNAME="ec2-user"
# SOURCE_FILE="/tmp/secrets.txt"
# DESTINATION_DIRECTORY="/tmp/"
# PRIVATE_KEY="web-ec2.pem"

# # Copy the file from the worker node to the bastion host using SCP
# ssh -i "$PRIVATE_KEY" "$BASTION_USERNAME@$BASTION_HOST" 

# sudo scp -i "$PRIVATE_KEY" "$WORKER_NODE_USERNAME@$WORKER_NODE_IP:$SOURCE_FILE" "$BASTION_USERNAME@$BASTION_HOST:$DESTINATION_DIRECTORY"
# # scp -i "web-ec2.pem" ec2-user@10.0.12.152:/tmp/secrets.txt ec2-user@54.204.254.232:/tmp/



# #!/bin/bash

# BASTION_HOST="${BASTION_HOST}"  # Replace with actual bastion hostname or IP
# WORKER_NODE_IP="${WORKER_NODE_IP}"  # Replace with actual private server IP
# PRIVATE_KEY="web-ec2.pem"
# BASTION_USER=ec2-user
# WORKER_NODE_USER=ec2-user

# # SSH into the bastion server
# ssh -i "$PRIVATE_KEY" ec2-user@"$BASTION_HOST" << EOF

# # Append SSH configuration to the config file
# cat << EOT >> /home/ec2-user/.ssh/config
# Host private-server
#   Hostname $WORKER_NODE_IP
#   ProxyJump $BASTION_HOST
#   IdentityFile /home/ec2-user/web-ec2.pem
#   User $BASTION_USER
# EOT
# EOF

