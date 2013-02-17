require 'json'
require 'yaml'

# Can open public URL with this http://nikeplus.nike.com/plus/activity/running/adamloving/detail/2099952663
class NikeHelper

  def poll(user)
    data = get_data(user)
    process_data(data, user)
    delta = get_delta(user)
    post_update(delta, user)
  end

  # protected

  def get_data(user)
    url = "https://api.nike.com/me/sport/activities?access_token=#{user.nike_access_token}"
    data = `curl -H "appid: fuelband" -H "Accept: application/json" "#{url}"`
    data = JSON.parse(data)

    # data = JSON.parse(open('test/fixtures/nike-activity-sample.js').read)
    puts data.to_yaml
    data
  end

  def process_data(data, user)
    for activity in data['data']
      if activity['deviceType'] == 'FUELBAND'
        puts "STEPS: #{activity['startTime']} #{activity['steps']}"

        sample = Sample.new(
          user: user,
          start_at: DateTime.parse(activity['startTime']).to_time,
          end_at: DateTime.now.to_time,
          steps: activity['steps']
        )
    
        existing_sample = Sample.where('start_at = ?', sample.start_at).order('start_at').last
        
        if !existing_sample
          puts "NEW ONE"
          sample.save
        elsif existing_sample && sample.start_at > 24.hours.ago # is it today?
          puts "TODAY"
          sample.start_at = existing_sample.end_at
          sample.steps = sample.steps - existing_sample.steps
          sample.save if sample.steps > 0
        end
      end
    end
  end

  def get_delta(user)
    since = user.last_report_time || 100.years.ago
    samples = Sample.where('created_at > ?', since).order('start_at')
    steps = samples.sum { |s| s.steps }
    
    {
      steps: steps,
      since: since
    }
  end

  def post_update(delta, user)
    return unless delta[:steps] > 0

    `curl --data "from=#{user.email}&subject=#{delta[:steps]} steps steps took" #{ENV['FEATBEAT_API_URL']}`
    user.update_attribute(:last_report_time, DateTime.now)
  end

end