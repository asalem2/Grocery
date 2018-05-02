module Homebrew
  module Diagnostic
    class Checks
      undef development_tools_checks, fatal_development_tools_checks,
            build_error_checks

      def development_tools_checks
        %w[
          check_for_unsupported_macos
          check_for_installed_developer_tools
          check_xcode_license_approved
          check_xcode_up_to_date
          check_clt_up_to_date
          check_for_other_package_managers
        ].freeze
      end

      def fatal_development_tools_checks
        %w[
          check_xcode_minimum_version
          check_clt_minimum_version
          check_if_xcode_needs_clt_installed
        ].freeze
      end

      def build_error_checks
        (development_tools_checks + %w[
          check_for_unsupported_macos
        ]).freeze
      end

      def check_for_unsupported_macos
        return if ARGV.homebrew_developer?

        who = "We"
        if OS::Mac.prerelease?
          what = "pre-release version"
        elsif OS::Mac.outdated_release?
          who << " (and Apple)"
          what = "old version"
        else
          return
        end

        <<~EOS
          You are using macOS #{MacOS.version}.
          #{who} do not provide support for this #{what}.
          You may encounter build failures or other breakages.
          Please create pull-requests instead of filing issues.
        EOS
      end

      def check_xcode_up_to_date
        return unless MacOS::Xcode.outdated?

        # Travis CI images are going to end up outdated so don't complain when
        # `brew test-bot` runs `brew doctor` in the CI for the Homebrew/brew
        # repository. This only needs to support whatever CI provider
        # Homebrew/brew is currently using.
        return if ENV["TRAVIS"]

        message = <<~EOS
          Your Xcode (#{MacOS::Xcode.version}) is outdated.
          Please update to Xcode #{MacOS::Xcode.latest_version} (or delete it).
          #{MacOS::Xcode.update_instructions}
        EOS

        if OS::Mac.prerelease?
          current_path = Utils.popen_read("/usr/bin/xcode-select", "-p")
          message += <<~EOS
            If #{MacOS::Xcode.latest_version} is installed, you may need to:
              sudo xcode-select --switch /Applications/Xcode.app
            Current developer directory is:
              #{current_path}
          EOS
        end
        message
      end

      def check_clt_up_to_date
        return unless MacOS::CLT.outdated?

        # Travis CI images are going to end up outdated so don't complain when
        # `brew test-bot` runs `brew doctor` in the CI for the Homebrew/brew
        # repository. This only needs to support whatever CI provider
        # Homebrew/brew is currently using.
        return if ENV["TRAVIS"]

        <<~EOS
          A newer Command Line Tools release is available.
          #{MacOS::CLT.update_instructions}
        EOS
      end

      def check_xcode_minimum_version
        return unless MacOS::Xcode.below_minimum_version?

        <<~EOS
          Your Xcode (#{MacOS::Xcode.version}) is too outdated.
          Please update to Xcode #{MacOS::Xcode.latest_version} (or delete it).
          #{MacOS::Xcode.update_instructions}
        EOS
      end

      def check_clt_minimum_version
        return unless MacOS::CLT.below_minimum_version?

        <<~EOS
          Your Command Line Tools are too outdated.
          #{MacOS::CLT.update_instructions}
        EOS
      end

      def check_if_xcode_needs_clt_installed
        return unless MacOS::Xcode.needs_clt_installed?

        <<~EOS
          Xcode alone is not sufficient on #{MacOS.version.pretty_name}.
          #{DevelopmentTools.installation_instructions}
        EOS
      end

      def check_for_other_package_managers
        ponk = MacOS.macports_or_fink
        return if ponk.empty?

        <<~EOS
          You have MacPorts or Fink installed:
            #{ponk.join(", ")}

          This can cause trouble. You don't have to uninstall them, but you may want to
          temporarily move them out of the way, e.g.

            sudo mv /opt/local ~/macports
        EOS
      end

      def check_ruby_version
        ruby_version = "2.3.3"
        return if RUBY_VERSION == ruby_version
        return if ARGV.homebrew_developer? && OS::Mac.prerelease?

        <<~EOS
          Ruby version #{RUBY_VERSION} is unsupported on #{MacOS.version}. Homebrew
          is developed and tested on Ruby #{ruby_version}, and may not work correctly
          on other Rubies. Patches are accepted as long as they don't cause breakage
          on supported Rubies.
        EOS
      end

      def check_xcode_prefix
        prefix = MacOS::Xcode.prefix
        return if prefix.nil?
        return unless prefix.to_s.include?(" ")

        <<~EOS
          Xcode is installed to a directory with a space in the name.
          This will cause some formulae to fail to build.
        EOS
      end

      def check_xcode_prefix_exists
        prefix = MacOS::Xcode.prefix
        return if prefix.nil? || prefix.exist?

        <<~EOS
          The directory Xcode is reportedly installed to doesn't exist:
            #{prefix}
          You may need to `xcode-select` the proper path if you have moved Xcode.
        EOS
      end

      def check_xcode_select_path
        return if MacOS::CLT.installed?
        return unless MacOS::Xcode.installed?
        return if File.file?("#{MacOS.active_developer_dir}/usr/bin/xcodebuild")

        path = MacOS::Xcode.bundle_path
        path = "/Developer" if path.nil? || !path.directory?
        <<~EOS
          Your Xcode is configured with an invalid path.
          You should change it to the correct path:
            sudo xcode-select -switch #{path}
        EOS
      end

      def check_for_bad_curl
        return unless MacOS.version <= "10.8"
        return if Formula["curl"].installed?

        <<~EOS
          The system curl on 10.8 and below is often incapable of supporting
          modern secure connections & will fail on fetching formulae.

          We recommend you:
            brew install curl
        EOS
      end

      def check_xcode_license_approved
        # If the user installs Xcode-only, they have to approve the
        # license or no "xc*" tool will work.
        return unless `/usr/bin/xcrun clang 2>&1` =~ /license/ && !$CHILD_STATUS.success?

        <<~EOS
          You have not agreed to the Xcode license.
          Builds will fail! Agree to the license by opening Xcode.app or running:
            sudo xcodebuild -license
        EOS
      end

      def check_xquartz_up_to_date
        return unless MacOS::XQuartz.outdated?

        <<~EOS
          Your XQuartz (#{MacOS::XQuartz.version}) is outdated.
          Please install XQuartz #{MacOS::XQuartz.latest_version} (or delete the current version).
          XQuartz can be updated using Homebrew-Cask by running
            brew cask reinstall xquartz
        EOS
      end

      def check_for_beta_xquartz
        return unless MacOS::XQuartz.version.to_s.include?("beta")

        <<~EOS
          The following beta release of XQuartz is installed: #{MacOS::XQuartz.version}

          XQuartz beta releases include address sanitization, and do not work with
          all software; notably, wine will not work with beta releases of XQuartz.
          We recommend only installing stable releases of XQuartz.
        EOS
      end

      def check_filesystem_case_sensitive
        dirs_to_check = [
          HOMEBREW_PREFIX,
          HOMEBREW_REPOSITORY,
          HOMEBREW_CELLAR,
          HOMEBREW_TEMP,
        ]
        case_sensitive_dirs = dirs_to_check.select do |dir|
          # We select the dir as being case-sensitive if either the UPCASED or the
          # downcased variant is missing.
          # Of course, on a case-insensitive fs, both exist because the os reports so.
          # In the rare situation when the user has indeed a downcased and an upcased
          # dir (e.g. /TMP and /tmp) this check falsely thinks it is case-insensitive
          # but we don't care because: 1. there is more than one dir checked, 2. the
          # check is not vital and 3. we would have to touch files otherwise.
          upcased = Pathname.new(dir.to_s.upcase)
          downcased = Pathname.new(dir.to_s.downcase)
          dir.exist? && !(upcased.exist? && downcased.exist?)
        end
        return if case_sensitive_dirs.empty?

        volumes = Volumes.new
        case_sensitive_vols = case_sensitive_dirs.map do |case_sensitive_dir|
          volumes.get_mounts(case_sensitive_dir)
        end
        case_sensitive_vols.uniq!

        <<~EOS
          The filesystem on #{case_sensitive_vols.join(",")} appears to be case-sensitive.
          The default macOS filesystem is case-insensitive. Please report any apparent problems.
        EOS
      end

      def check_homebrew_prefix
        return if HOMEBREW_PREFIX.to_s == "/usr/local"

        <<~EOS
          Your Homebrew's prefix is not /usr/local.
          You can install Homebrew anywhere you want but some bottles (binary packages)
          can only be used with a /usr/local prefix and some formulae (packages)
          may not build correctly with a non-/usr/local prefix.
        EOS
      end
    end
  end
end
