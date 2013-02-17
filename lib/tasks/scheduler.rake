desc "This task is called by the Heroku scheduler add-on"

task :poll_everybody => :environment do
  NikeHelper.poll_everybody
end