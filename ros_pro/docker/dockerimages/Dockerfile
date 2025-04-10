# Use the official ROS Noetic desktop-full image
FROM osrf/ros:noetic-desktop-full

# Install basic utilities
RUN apt-get update && apt-get install -y nano && rm -rf /var/lib/apt/lists/*

# Define a non-root user
ARG USERNAME=noetic
ARG USER_ID=1000
ARG USER_GID=1000

# Create the user and group
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_ID --gid $USER_GID -m $USERNAME \
    && mkdir -p /home/$USERNAME/.config && chown -R $USERNAME:$USERNAME /home/$USERNAME

# Set up environment variables
ENV DISPLAY=host.docker.internal:0.0
ENV ROS_MASTER_URI=http://localhost:11311
ENV ROS_HOSTNAME=localhost

# Set the shell to bash
SHELL ["/bin/bash", "-c"]

# Create a catkin workspace
RUN mkdir -p /home/$USERNAME/catkin_ws/src

# Copy source code into the workspace
COPY --chown=$USERNAME:$USERNAME ./src /home/$USERNAME/catkin_ws/src

# Copy install scripts
COPY --chown=$USERNAME:$USERNAME ./install /home/$USERNAME/install

# Install dependencies as root before switching users
RUN chmod +x /home/$USERNAME/install/i_dep.sh && \
    /home/$USERNAME/install/i_dep.sh

# Set up X11 authentication
RUN chmod +x /home/$USERNAME/install/xauth.sh

# Set ownership of catkin workspace to the non-root user
RUN chown -R $USERNAME:$USERNAME /home/$USERNAME/catkin_ws

# Switch to the non-root user
USER $USERNAME
WORKDIR /home/$USERNAME/catkin_ws

# Build the catkin workspace
RUN /bin/bash -c "source /opt/ros/noetic/setup.bash && catkin_make"

# Source the catkin workspace in .bashrc
RUN echo "source /opt/ros/noetic/setup.bash" >> /home/$USERNAME/.bashrc
RUN echo "source /home/$USERNAME/catkin_ws/devel/setup.bash" >> /home/$USERNAME/.bashrc

# Set the entrypoint to run xauth.sh and start bash
ENTRYPOINT ["/home/noetic/install/xauth.sh"]
CMD ["bash"]
