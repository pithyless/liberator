require 'bundler/setup'
require 'sinatra'
require 'grit'
require 'coderay'
require 'time-lord'
require 'digest/md5'

helpers do
  def get_repo(name)
    unless @open_repos
      @open_repos = {
        'stringex' =>  Grit::Repo.new("/Users/norbert/code/lib/stringex"),
        'liberator' => Grit::Repo.new("/Users/norbert/code/play/liberator"),
      }
    end
    @open_repos[name]
  end

  def render_diff(diff)
    CodeRay.scan(diff, :diff).div(:css => :class)
  end

  def format_long_ago(from_time)
    if from_time.is_a? String
      from_time = Time.parse(from_time)
    end
    if from_time < Time.now - Time::Week
      from_time.strftime('%b %d, %Y')
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

  def group_by_committed_date(commits)
    cs = commits.group_by { |c| c.committed_date.strftime('%Y-%m-%d') }.sort
    cs.reverse!
    cs.map! { |d,cs| [Time.parse(d), cs] }
  end

  def branch_or_404(repo, branch)
    branch = branch.to_s
    branches = repo.branches.map(&:name)
    raise NotFound unless branches.include?(branch)
    branch
  end
end

get '/' do
  @commits = []
  erb :index
end

before '/repo/:slug/*' do |slug, extras|
  @repo = get_repo(slug) or raise NotFound
  @repo_name = params[:slug]
end

get '/repo/:slug' do
  redirect "/repo/#{params[:slug]}/commits"
end

get '/repo/:slug/commits' do
  redirect "/repo/#{params[:slug]}/commits/master"
end

get '/repo/:slug/commits/:branch' do
  commits_limit = 75
  branch = branch_or_404(@repo, params[:branch])
  commits = @repo.commits(branch, commits_limit)
  @group_commits = group_by_committed_date(commits).map do |d, cs|
    [d.strftime('%b %d, %Y'), cs]
  end
  erb :commits
end

get '/repo/:slug/commits/:from_branch/:to_branch' do
  from_branch = branch_or_404(@repo, params[:from_branch])
  to_branch = branch_or_404(@repo, params[:to_branch])
  commits = @repo.commits_between(from_branch, to_branch).reverse
  @group_commits = group_by_committed_date(commits).map do |d, cs|
    [d.strftime('%b %d, %Y'), cs]
  end
  erb :commits
end

get '/repo/:slug/commits/:from_branch/:to_branch/diff' do
  from_branch = branch_or_404(@repo, params[:from_branch])
  to_branch = branch_or_404(@repo, params[:to_branch])
  @diffs = @repo.diff(from_branch, to_branch)
  erb :diff
end

get '/repo/:slug/commit/:sha' do
  @commit = @repo.commit(params[:sha])
  erb :commit
end
