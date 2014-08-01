module.exports = {
  up: function(migration, DataTypes, done) {
    migration.createTable(
        'receipts',
        {
          id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true
          },
          createdAt: {
            type: DataTypes.DATE
          },
          updatedAt: {
            type: DataTypes.DATE
          },
          request_content: {
            type: DataTypes.TEXT,
            allowNull: false
          },
          response_content: {
            type: DataTypes.TEXT,
            allowNull: false
          }
        }
    );

    done();
  },

  down: function(migration, DataTypes, done) {
    migration.dropTable('receipts');
      done();
  }
};
