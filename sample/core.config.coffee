module.exports =
  web:
    name: 'RootPanel'
    url: 'http://rpvhost.net'
    listen: '/home/rpadmin/rootpanel.sock'
    google_analytics_id: 'UA-49193300-2'

  account:
    cookie_time: 30 * 24 * 3600 * 1000

  i18n:
    available_language: ['zh_CN']
    default_language: 'zh_CN'
    default_timezone: 'Asia/Shanghai'

  plugin:
    available_extensions: []
    available_services: []

  billing:
    currency: 'CNY'

    force_freeze:
      when_balance_below: 0
      when_arrears_above: 0

    billing_cycle: 10 * 60 * 1000

  plans:
    sample:
      t_name: 'plans.sample.name'
      t_description: 'plans.sample.name.description'

      billing_by_time:
        unit: 3600 * 1000
        min_billing_unit: 24

        price: 10 / (30 * 24)

      services: []
      resources: {}

    test:
      t_name: 'plans.test.name'
      t_description: 'plans.test.name.description'

      billing_by_usage:
        auto_leave: 7 * 24 * 3600 * 1000

      services: []
      resources: {}

  mongodb:
    user: 'rpadmin'
    password: 'password'
    host: 'localhost'
    name: 'RootPanel'

  redis:
    host: '127.0.0.1'
    port: 6379
    password: 'password'
    prefix: 'RP'

  redis_password: 'password'

  email:
    send_from: 'robot@rpvhost.net'

    account:
      service: 'Postmark'
      auth:
        user: 'postmark-api-token'
        pass: 'postmark-api-token'

  plugins: {}