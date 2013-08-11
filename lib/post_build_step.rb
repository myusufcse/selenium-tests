require File.dirname(__FILE__) + "/step.rb"

module Jenkins
  class PostBuildStep
    include Jenkins::Step

    def self.add(job, title)

      click_button 'Add post-build action'
      click_link label(title)

      sleep 1
      prefix = all(:xpath, "//div[@name='publisher']").last[:path]

      return type(title).new(job, prefix)
    end

    @@types = Hash.new

    def self.register(title, label)
      raise "#{title} already registered" if @@types.has_key? title

      @@types[title] = {type: self, label: label}
    end

    def self.get(title)
      return @@types[title] if @@types.has_key? title

      raise "Unknown #{self.name.split('::').last} type #{title}. #{@@types.keys}"
    end
  end

  class ArtifactArchiver < PostBuildStep

    register 'Artifact Archiver', 'Archive the artifacts'

    def self.add(job)

      click_button 'Add post-build action'

      title = 'Artifact Archiver'
      begin
        click_link label title
      rescue Capybara::ElementNotFound
        # When cloudbees-jsync-archiver installed (pending JENKINS-17236):
        click_link 'Archive artifacts (fast)'
      end

      sleep 1
      prefix = all(:xpath, "//div[@name='publisher']").last[:path]

      return type(title).new(job, prefix)
    end

    def includes(includes)
      find(:path, path("artifacts")).set includes
    end

    def excludes(excludes)
      find(:path, path("advanced-button")).locate.click
      find(:path, path("excludes")).set excludes
    end

    def latest_only(latest)
      find(:path, path("advanced-button")).locate.click
      find(:path, path("latestOnly")).set latest
    end
  end
end