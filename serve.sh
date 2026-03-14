# Install requirements
# $ sudo apt-get install ruby-full build-essential zlib1g-dev

# Setup GEM bins install path
# $ echo '# Install Ruby Gems to ~/gems' >> ~/.bashrc
# $ echo 'export GEM_HOME=$HOME/gems' >> ~/.bashrc
# $ echo 'export PATH=$GEM_HOME/bin:$PATH' >> ~/.bashrc
# $ source ~/.bashrc

# Install GEM requirements
# $ bundle install

# Serve jekyll
bundle exec jekyll serve
