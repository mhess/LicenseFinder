module LicenseFinder
  class MavenPackage < Package
    attr_reader :mvn_dependency

    def initialize(mvn_dependency, options={})
      super options
      @mvn_dependency = mvn_dependency
    end

    def name
      mvn_dependency["artifactId"]
    end

    def version
      mvn_dependency["version"]
    end

    def description
      ""
    end

    def summary
      ""
    end

    def homepage
      ""
    end

    def groups
      []
    end

    def children
      []
    end

    def license_names_from_spec
      mvn_dependency["licenses"].map { |l| l["name"] }
    end
  end
end
