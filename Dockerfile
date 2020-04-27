# This stage builds the sapper application.
FROM mhart/alpine-node:12 AS build-app
WORKDIR /app
COPY . .
RUN npm install --no-audit --unsafe-perm
RUN npm run build

# This stage installs the runtime dependencies.
FROM mhart/alpine-node:12 AS build-runtime
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --production --unsafe-perm

# This stage only needs the compiled Sapper application
# and the runtime dependencies.
FROM mhart/alpine-node:slim-12
WORKDIR /app
COPY --from=build-app /app/__sapper__ ./__sapper__
COPY --from=build-app /app/static ./static
COPY --from=build-runtime /app/node_modules ./node_modules

EXPOSE 3000
CMD ["node", "__sapper__/build"]