# Setting up a simpler trimmed container for SRE/DevOps work
# -----------------------------------------

# k6 Stage
FROM loadimpact/k6:latest as k6-stage

# Final Stage
# ------------
FROM ubuntu:latest

# Copy k6 from the k6 stage
COPY --from=k6-stage /usr/bin/k6 /usr/bin/k6

# Update and install necessary basic packages
RUN apt-get update && apt-get install -y curl git wget bash-completion software-properties-common groff unzip tree

# Set up a non-root user and set working directory
RUN useradd -m sre

# Kubernetes: kubectl, kubectx, kubens, Helm
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl && \
    git clone https://github.com/ahmetb/kubectx.git /opt/kubectx && \
    ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx && \
    ln -s /opt/kubectx/kubens /usr/local/bin/kubens && \
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh

# Terraform and Terragrunt
RUN git clone --depth=1 https://github.com/tfutils/tfenv.git /opt/tfenv && \
    git clone --depth=1 https://github.com/tgenv/tgenv.git /opt/tgenv && \
    chown -R sre:sre /opt/tfenv && \
    chown -R sre:sre /opt/tgenv

# AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy files from the current directory to /home/sre in the container
COPY . /home/sre

# Set environment PATH for all users
ENV PATH="/opt/tfenv/bin:/opt/tgenv/bin:/usr/local/bin/kubectx:/usr/local/bin/kubens:/usr/local/bin:${PATH}"

USER sre
WORKDIR /home/sre

# Start bash shell
CMD ["/bin/bash"]
