module.exports = (sequelize, DataTypes) ->
  sequelize.define "Receipt",
    request_content: DataTypes.TEXT
    response_content: DataTypes.TEXT
