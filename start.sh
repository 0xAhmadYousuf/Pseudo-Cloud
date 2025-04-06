#!/bin/bash

# Set the terminal type to xterm-256color
export TERM=xterm-256color

# Configure zsh for color support
echo "alias ls='ls --color=auto'" >> ~/.zshrc
echo "alias grep='grep --color=auto'" >> ~/.zshrc
echo "export CLICOLOR=1" >> ~/.zshrc
echo "export LSCOLORS='ExFxCxDxBxegedabagacad'" >> ~/.zshrc
echo "export GREP_COLOR='1;32'" >> ~/.zshrc



# Start cloudflared tunnel in the background with a random domain
cloudflared tunnel --url http://localhost:5000 --no-autoupdate &
# Wait a few seconds to allow the tunnel to start (optional)
sleep 3

# Start the Flask application
exec python3 app.py



# # make a example html file with multiple lines
# echo "<html>
#         <head>
#           <title>My Flask App</title>
#         </head>
#         <body>
#           <h1>Welcome to My Flask App</h1>
#           <p>This is a simple Flask application running on Cloudflare Tunnel.</p>
#           <p>Here are some example lines:</p>
#           <ul>
#             <li>Line 1: This is the first line.</li>
#             <li>Line 2: This is the second line.</li>
#             <li>Line 3: This is the third line.</li>
#           </ul>
#           <p>Feel free to modify this HTML file as needed.</p>
#           <p>Enjoy!</p>
#         </body>
#       </html>" > index.html

# # move it to the template folder
# mv index.html templates/index.html

