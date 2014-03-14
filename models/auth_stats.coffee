require "date-utils"
Emailer = require "../lib/emailer"

module.exports = (sequelize, DataTypes) ->

  AuthStats = sequelize.define "AuthStats",
      user_id:
        type: DataTypes.INTEGER.UNSIGNED
        allowNull: false
      ip:
        type: DataTypes.STRING
        allowNull: true
    ,
      tableName: "auth_stats"
      classMethods:

        findByUser: (userId, callback = ()->)->
          AuthStats.findAll({where: {user_id: userId}}).complete callback
        
        log: (data, sendByMail = true, callback = ()->)->
          stats =
            user_id: data.user.id
            ip: data.ip
          AuthStats.create(stats).complete (err, authStats)->
            AuthStats.sendUserLoginNotice authStats, data.user.email  if sendByMail
            callback err, stats

        sendUserLoginNotice: (stats, email, callback = ()->)->
          siteUrl = GLOBAL.appConfig().emailer.host
          data =
            site_url: siteUrl
            ip: stats.ip or "unknown"
            auth_date: stats.created_at.toFormat "MMMM D, YYYY at HH24:MI"
            email: email
          options =
            to:
              email: email
            subject: "Login on Coinnext.com"
            template: "user_login_notice"
          emailer = new Emailer options, data
          emailer.send (err, result)->
            console.error err  if err
          callback()

  AuthStats