ENV['SHOPIFY'] = "TRUE" if Dir.exist? ('/opt/dev') or ENV['SPIN']

task :default => [:git, :zsh, :brew]

task :git do
  sh "erb gitconfig.erb > ~/.gitconfig"
  sh "erb gitconfig_shopify.erb > ~/.gitconfig_shopify" if ENV['SHOPIFY']
end

task :zsh do 
  sh "erb zshrc.erb > ~/.zshrc"
end

task :brew do
  if Dir.exist? '/opt/homebrew'
    sh "brew bundle --file=Brewfile"
  end
end