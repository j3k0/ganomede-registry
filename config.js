module.exports = {
    proxyPort: +process.env.PROXY_PORT || 8080,
    port: +process.env.PORT || 8000,
    routePrefix: process.env.ROUTE_PREFIX || "registry"
};
