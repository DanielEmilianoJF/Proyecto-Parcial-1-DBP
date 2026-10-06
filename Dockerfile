FROM debian:stable-slim

WORKDIR /app
COPY app.sh /app/app.sh
COPY datos/ /app/datos/
RUN chmod +x /app/app.sh

# El script se ejecuta automáticamente al iniciar el contenedor.
# Si no se indica parámetro, se usa -a (se puede cambiar con: docker run -it imagen -t)
ENTRYPOINT ["/app/app.sh"]
CMD ["-a"]
