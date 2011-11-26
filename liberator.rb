require 'bundler/setup'
require 'sinatra'

require 'grit'
require 'coderay'

helpers do
  def repo
    @repo ||= Grit::Repo.new("/Users/norbert/code/lib/stringex")
  end

  def render_diff(diff)
    CodeRay.scan(diff, :diff).div(:css => :class)
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
