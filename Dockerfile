# Dockerfile
FROM debian:latest

# Install inotify-tools and OpenSSH server
RUN apt-get update && apt-get install -y inotify-tools openssh-server vsftpd rsync
# Create the SSH directory and copy the authorized_keys file
COPY authorized_keys /root/.ssh/authorized_keys
COPY sshd_config /etc/ssh/sshd_config
RUN chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys

# Configure SSH to use port 2222
RUN sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config

RUN echo "local_enable=YES\nwrite_enable=YES\nchroot_local_user=YES\nlocal_umask=022\n" >> /etc/vsftpd.conf
RUN echo 'allow_writeable_chroot=YES' >> /etc/vsftpd.conf
RUN mkdir -p /srv/upload
RUN useradd -m -d /srv/upload <REPLACE-WITH-YOUR-USERNAME> && \
    echo '<REPLACE-WITH-YOUR-USERNAME>:<REPLACE-WITH-YOUR-USER-PASSWORD>' | chpasswd

# Copy the script that will run and monitor acServer processes
COPY run_ac_servers.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run_ac_servers.sh

RUN chown -R <REPLACE-WITH-YOUR-USERNAME>:<REPLACE-WITH-YOUR-USERNAME> /srv/upload

# Mount /srv/servers directory
VOLUME ["/srv/template"]

# Copy the startup script
COPY start_services.sh /usr/local/bin/start_services.sh
RUN chmod +x /usr/local/bin/start_services.sh


# Set the command to run the startup script
CMD ["/usr/local/bin/start_services.sh"]


