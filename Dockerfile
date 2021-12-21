FROM bartversluijs/versionist:v6.6.3

# Add entrypoint
COPY entrypoint.sh /entrypoint.sh

CMD [ "/entrypoint.sh" ]
