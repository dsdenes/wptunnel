FROM wordpress:latest
COPY ./docker-entrypoint-seturl.sh .
ENTRYPOINT ["./docker-entrypoint-seturl.sh"]
CMD ["apache2-foreground"]