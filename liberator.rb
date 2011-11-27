require 'bundler/setup'
require 'sinatra'
require 'grit'
require 'coderay'
require 'time-lord'
require 'digest/md5'
require 'cgi'

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

  def gravatar(email, size=32)
    missing = 'identicon'
    email = email.strip.downcase
    hash = Digest::MD5.hexdigest(email)
    src = "https://secure.gravatar.com/avatar/#{hash}?s=#{size}&amp;d=#{missing}"
    "<img class=\"gravatar\" height=\"#{size}\" width=\"#{size}\" src=\"#{src}\">"
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
