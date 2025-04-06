![Asset 5@5x-100](https://github.com/user-attachments/assets/6f973790-1429-4d92-be14-e39b43a37dc4)

# Pseudo-Cloud
Pseudo-Cloud is a web application that emulates a cloud terminal experience, allowing users to interact with a simulated cloud environment through their browser. This project utilizes Docker for containerization and Cloudflare Tunnels to securely expose the application to the internet without the need for a public IP address or complex firewall configurations.

## Features

- **Terminal Emulation**: Provides a simulated cloud terminal interface accessible via a web browser.
- **Dockerized Deployment**: Simplifies setup and deployment using Docker containers.
- **Secure Access with Cloudflare Tunnels**: Exposes the application securely without requiring a public IP or modifying firewall settings.

## Prerequisites

- **Docker**: Ensure Docker is installed on your machine. [Install Docker](https://docs.docker.com/get-docker/)

## Setup and Deployment

1. **Clone the Repository**

   ```bash
   git clone https://github.com/0xAhmadYousuf/Pseudo-Cloud.git
   cd Pseudo-Cloud
   ```

2. **Build the Docker Image**

   Build the Docker image using the provided Dockerfile:

   ```bash
   docker build -t pseudo-cloud .
   ```

3. **Run the Application**

   Start the application in detached mode:

   ```bash
   docker run -d -p 5000:5000 pseudo-cloud
   ```

   This command runs the application on port 5000 of your local machine.

4. **Start Cloudflare Tunnel**

   Cloudflare Tunnel allows you to expose your local server to the internet securely. To set up the tunnel:

   - **Download cloudflared**: Obtain the appropriate version of `cloudflared` for your operating system from Cloudflare's [GitHub releases](https://github.com/cloudflare/cloudflared/releases).

   - **Authenticate cloudflared**: Run the following command to authenticate and create a tunnel:

     ```bash
     cloudflared tunnel --url http://localhost:5000 --no-autoupdate &
     ```

     This command establishes a secure tunnel from Cloudflare to your local application. Cloudflare will generate a random subdomain under `trycloudflare.com` (e.g., `weak-atm-ways-provides.trycloudflare.com`) that you can use to access your application from anywhere.

   - **Optional - Wait for Tunnel to Initialize**: To ensure the tunnel has sufficient time to establish, you can add a brief pause:

     ```bash
     sleep 3
     ```

     This step is optional but recommended to prevent potential timing issues.

## Accessing the Application

After setting up the Cloudflare Tunnel, you can access your application through the generated URL (e.g., `weak-atm-ways-provides.trycloudflare.com`). This URL is publicly accessible and routes traffic securely to your local server.

## Stopping the Application and Tunnel

To stop the application and the Cloudflare Tunnel:

1. **Stop the Docker Container**

   List running containers to find the container ID:

   ```bash
   docker ps
   ```

   Stop the container using its ID:

   ```bash
   docker stop <container_id>
   ```

2. **Terminate the Cloudflare Tunnel**

   Identify the process ID (PID) of `cloudflared`:

   ```bash
   ps aux | grep cloudflared
   ```

   Terminate the process:

   ```bash
   kill <pid>
   ```

## Notes

- **No Cloudflare Account Required**: This setup uses Cloudflare's accountless tunnel feature, eliminating the need for a Cloudflare account or manual certificate generation. [Learn more](https://community.cloudflare.com/t/only-accountless-tunnels-with-docker-compose/442445).

- **Persistent Tunnel URL**: Each time you start the tunnel, Cloudflare generates a new subdomain. To maintain a consistent URL, consider registering a domain and configuring Cloudflare accordingly.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 
