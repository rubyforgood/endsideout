class AdrGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  def create_adr_file
    template "adr.md.erb", adr_path
  end

  private

  def adr_path
    "docs/adrs/#{next_number}_#{name.underscore.parameterize(separator: "_")}.md"
  end

  def next_number
    @next_number ||= begin
      existing = Dir[File.join(destination_root, "docs/adrs/[0-9]*.md")].map { |f| File.basename(f).to_i }.max || 0
      format("%04d", existing + 1)
    end
  end
end
