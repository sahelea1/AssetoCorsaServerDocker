# AssetoCorsaServerDocker
Scripts and Dockerfiles to run and automaticaly deploy multiple asseto corsa servers / instances in a docker container. (+ftp)
Ports for the server are autoconfigured (range defined in run_ac_server.sh). Adjust if needed.

Setup:
1. Clone repo
2. Add your ssh pubkey to authorized_keys file
3. Adjust Dockerfile and sshd_config (replace username and password with one of your choice)
4. Upload the content of the ./server directory in your asseto installation into the ./template folder.
5. docker-compose up --build -d

You can now ftp onto the server with your chosen username and password.
Simply place config files in a seperate directoy for each server in the root dir of the ftp server.
To reload / sync servers, simply create a file called "start" -> will be deleted automatically afterwards.
Also possible to stop servers like that. (with "stop" file)



Enjoy :)
