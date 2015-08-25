CarrierWave.configure do |config|
  config.fog_credentials = {
    provider: 'AWS',
    aws_access_key_id: ENV['QT_AWS_ACCESS_KEY_ID'],
    aws_secret_access_key: ENV['QT_AWS_SECRET_ACCESS_KEY'],
    region: ENV['QT_AWS_REGION']
  }
  config.fog_directory = ENV['QT_AWS_BUCKET']
end