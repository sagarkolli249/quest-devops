# Fetching the minified node image on apline linux
FROM node:slim

# Declaring env
ENV NODE_ENV development

# Setting up the work directory
WORKDIR /express-docker

# Copying all the files in our project
COPY . .

# Installing dependencies
RUN npm install

#Set Secret Word
ENV SECRET_WORD=rearc

# Starting our application
CMD [ "node", "src/000.js" ]

# Exposing server port
EXPOSE 3000