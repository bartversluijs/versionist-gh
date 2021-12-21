FROM bartversluijs/versionist:v6.6.3
WORKDIR /usr/src/app

# Install bash
RUN apk add --update --no-cache bash

# Add entrypoint
COPY ./entrypoint.sh /usr/src/app/entrypoint.sh

# Run entrypoint
CMD [ "/usr/src/app/entrypoint.sh" ]
