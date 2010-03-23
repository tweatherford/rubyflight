# -*- ruby -*-
require 'rubygems'
require 'rake'
require 'echoe'
require 'yard'

Echoe.new('rubyflight') do |p|
  p.author = 'v01d'
  p.summary = "Flight Simulator binding"
  p.url = "http://github.com/v01d/ruby-gsl-ng"
  p.version = "0.1"
  p.dependencies = ['ffi']
end

Rake::TaskManager.class_eval do
  def remove_task(task)
    @tasks.delete(task.to_s)
  end
end

Rake.application.remove_task(:docs)
YARD::Rake::YardocTask.new(:docs) {|t| t.options = ['--verbose','--no-private','--hide-void']}

