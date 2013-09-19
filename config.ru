require "slim"
require "sinatra"

class App < Sinatra::Application
  set :slim, layout: :application

  get "/" do
    talks = Dir.glob(File.expand_path("../views/*.slim", __FILE__)).map { |path| File.basename(path).gsub(".slim", "") }.grep(/^\d{4}/)
    slim :index, locals: { talks: talks }
  end

  get "/talks/:title" do |title|
    slim title.to_sym, locals: { user_agent: env["HTTP_USER_AGENT"] }
  end

  def strip_leading_whitespace(lines)
    max = lines.scan(/^([\ ]+)/).flatten.map(&:length).sort.first
    lines.gsub(/^[\ ]{#{max}}/, "").strip
  end

  def format_code(content, fragment = true)
    content = content[/\/\/ SNIP_START\s*?(.*?)\/\/ SNIP_END/m, 1] ||
      content[/# SNIP_START\s*?(.*?)# SNIP_END/m, 1] ||
      content
    pre_tag = "<pre"
    pre_tag << %( class="fragment") if fragment
    %(#{pre_tag}><code>#{strip_leading_whitespace(content)}</code></pre>)
  end

  def asset_url(path)
    if params[:relative] == "true"
      return path
    else
      "/" + path
    end
  end


  get /.*/ do
    path = env["REQUEST_PATH"][1..-1]
    puts "path: #{path}"
    if !File.exists?(path)
      return [404, {}, ["Not Found"]]
    end
    ct = case path
    when /\.css$/
      "text/css"
    when /\.js$/
      "text/javascript"
    else
      "text/plain"
    end
    [200, { "Content-Type" => ct }, File.open(path)]
  end

  def format_code(content, fragment = true)
    content = content[/\/\/ SNIP_START\s*?(.*?)\/\/ SNIP_END/m, 1] ||
      content[/# SNIP_START\s*?(.*?)# SNIP_END/m, 1] ||
      content
    pre_tag = "<pre"
    pre_tag << %( class="fragment") if fragment
    %(#{pre_tag}><code>#{strip_leading_whitespace(content)}</code></pre>)
  end

  def strip_leading_whitespace(lines)
    max = lines.scan(/^([\ ]+)/).flatten.map(&:length).sort.first
    lines.gsub(/^[\ ]{#{max}}/, "").strip
  end
end

Slim::Engine.set_default_options pretty: true

run App.new

