require 'bundler/setup'
require 'sinatra'

require 'grit'
require 'coderay'
require 'time-lord'

helpers do
  def repo
    @repo ||= Grit::Repo.new("/Users/norbert/code/lib/stringex")
  end

  def render_diff(diff)
    CodeRay.scan(diff, :diff).div(:css => :class)
  end

  def format_long_ago(from_time)
    if from_time.is_a? String
      from_time = Time.parse(from_time)
    end
    if from_time < Time.now - Time::Week
      Time.now.strftime('%b %d, %Y')
    else
      from_time.ago_in_words
    end
  end
end

get '/' do
  @commits = repo.commits
  erb :index
end

get '/commit/:sha' do
  @commit = repo.commit(params[:sha])
  erb :commit
end
