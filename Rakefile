ENV['SHOPIFY'] = "TRUE" if Dir.exist? ('/opt/dev') or ENV['SPIN']

def erb(source, destination)
  sh "erb #{source} > #{destination}"
end

task :default => [:git, :zsh, :brew]

task :git do
  erb "gitconfig.erb", "#{Dir.home}/.gitconfig"
  cp "gitignore", "#{Dir.home}/.gitignore"
  if ENV['SHOPIFY']
    erb "gitconfig_shopify.erb", "#{Dir.home}/.gitconfig_shopify"
  end
end

task :zsh do 
  erb "zshrc.erb", "#{Dir.home}/.zshrc"
end

task :brew do
  if Dir.exist? '/opt/homebrew'
    sh "brew bundle --file=Brewfile"
  end
end