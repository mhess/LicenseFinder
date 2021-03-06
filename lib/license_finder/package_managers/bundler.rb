require "bundler"

module LicenseFinder
  class Bundler < PackageManager
    def initialize options={}
      super
      @ignore_groups = options[:ignore_groups] # dependency injection for tests
      @definition    = options[:definition]    # dependency injection for tests
    end

    def current_packages
      logger.log self.class, "including groups #{included_groups.inspect}"
      definition.specs_for(included_groups).map do |gem_def|
        bundler_def = bundler_defs.detect { |bundler_def| bundler_def.name == gem_def.name }
        BundlerPackage.new(gem_def, bundler_def, logger: logger).tap do |package|
          logger.package self.class, package
        end
      end
    end

    private

    def definition
      # DI
      @definition ||= ::Bundler::Definition.build(package_path, lockfile_path, nil)
    end

    def ignore_groups
      # DI
      @ignore_groups ||= LicenseFinder.config.ignore_groups
    end

    def package_path
      Pathname.new("Gemfile")
    end

    def bundler_defs
      # memoized
      @bundler_defs ||= definition.dependencies
    end

    def included_groups
      definition.groups - ignore_groups.map(&:to_sym)
    end

    def lockfile_path
      package_path.dirname.join('Gemfile.lock')
    end
  end
end
