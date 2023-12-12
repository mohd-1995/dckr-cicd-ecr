#using nginx as a base image for this dockerfile
FROM nginx:latest
WORKDIR /Users/mo_b/Desktop/github-projects/docker-cicd-ecs/hey.html
COPY hey.html /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]