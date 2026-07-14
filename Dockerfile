FROM nginx:alpine
COPY itinerary.html /usr/share/nginx/html/index.html
EXPOSE 80
