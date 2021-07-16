FROM bartversluijs/versionist:6.5.1

# Add entrypoint
COPY entrypoint.sh /entrypoint.sh

CMD [ "/entrypoint.sh" ]
