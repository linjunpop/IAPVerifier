unless global.hasOwnProperty("db")
  Sequelize = require("sequelize")
  sequelize = null

  match = process.env.DATABASE_URL.match(/postgres:\/\/([^:]+):([^@]+)@([^:]+):(\d+)\/(.+)/)
  sequelize = new Sequelize(match[5], match[1], match[2],
    dialect: "postgres"
    protocol: "postgres"
    port: match[4]
    host: match[3]
    logging: false
  )

  global.db =
    Sequelize: Sequelize
    sequelize: sequelize
    Receipt: sequelize.import(__dirname + "/receipt")

module.exports = global.db
