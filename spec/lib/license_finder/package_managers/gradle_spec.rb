require 'spec_helper'

module LicenseFinder
  describe Gradle do
    let(:gradle) { Gradle.new }
    it_behaves_like "a PackageManager"

    def license_xml(xml)
      <<-resp
        <dependencies>
          #{xml}
        </dependencies>
      resp
    end

    describe '.current_packages' do
      before do
        allow(LicenseFinder.config).to receive(:gradle_command) { 'gradlefoo' }
        expect(gradle).to receive('`').with(/gradlefoo downloadLicenses/)
      end

      it 'lists all the current packages' do
        license_xml = license_xml("""
          <dependency name='org.springframework:spring-aop:4.0.1.RELEASE'>
            <file>spring-aop-4.0.1.RELEASE.jar</file>
            <license name='The Apache Software License, Version 2.0' url='http://www.apache.org/licenses/LICENSE-2.0.txt' />
          </dependency>
          <dependency name='org.springframework:spring-core:4.0.1.RELEASE'>
            <file>spring-core-4.0.1.RELEASE.jar</file>
            <license name='The Apache Software License, Version 2.0' url='http://www.apache.org/licenses/LICENSE-2.0.txt' />
          </dependency>
        """)
        fake_file = double(:license_report, read: license_xml)
        allow(gradle).to receive(:license_report).and_return(fake_file)

        current_packages = gradle.current_packages

        expect(current_packages.size).to eq(2)
        expect(current_packages.first).to be_a(Package)
      end

      it "handles multiple licenses" do
        license_xml = license_xml("""
          <dependency>
            <license name='License 1'/>
            <license name='License 2'/>
          </dependency>
        """)

        fake_file = double(:license_report, read: license_xml)
        allow(gradle).to receive(:license_report).and_return(fake_file)

        expect(GradlePackage).to receive(:new).with({"license" => [{"name" => "License 1"}, {"name" => "License 2"}]}, anything)
        gradle.current_packages
      end

      it "handles no licenses" do
        license_xml = license_xml("""
          <dependency>
            <license name='No license found' />
          </dependency>
        """)

        fake_file = double(:license_report, read: license_xml)
        allow(gradle).to receive(:license_report).and_return(fake_file)

        expect(GradlePackage).to receive(:new).with({"license" => []}, anything)
        gradle.current_packages
      end

      it "handles an empty list of licenses" do
        license_xml = license_xml("")

        fake_file = double(:license_report, read: license_xml)
        allow(gradle).to receive(:license_report).and_return(fake_file)
        gradle.current_packages
      end
    end

    describe '.active?' do
      let(:package_path) { double(:package_file) }
      let(:gradle) { Gradle.new package_path: package_path }

      it 'is true with a build.gradle file' do
        allow(package_path).to receive_messages(:exist? => true)
        expect(gradle).to be_active
      end

      it 'is false without a build.gradle file' do
        allow(package_path).to receive_messages(:exist? => false)
        expect(gradle).to_not be_active
      end
    end
  end
end
