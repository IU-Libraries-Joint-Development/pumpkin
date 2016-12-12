# Collect content from server-local or "cloud" storage using
# browse-everything[https://github.com/projecthydra/browse-everything]
# and attach it to a repository object.
#
# The content is temporarily stored in a configurable directory -- see
# <tt>config[:upload_to]</tt>.

class BrowseEverythingIngester
  # repository object to receive this content
  attr_reader :curation_concern

  # TBD
  attr_reader :upload_set_id

  # installs the content
  attr_reader :actor

  # locator for the content
  attr_reader :file_info

  delegate :mime_type, :file_name, :file_path, to: :file_info

  # Configure this instance, but take no action yet.
  def initialize(curation_concern, upload_set_id, actor, file_info)
    @curation_concern = curation_concern
    @upload_set_id = upload_set_id
    @actor = actor
    @file_info = FileInfo.new(file_info.to_h)
  end

  # Get the content, provide it to an installer, and clean up scratch storage.
  def save
    actor.create_metadata(curation_concern, {})
    actor.create_content(decorated_file)
    cleanup_download
  end

  private

    # Return a handle to the local copy of the content.
    def file
      @file ||= File.open(downloaded_file_path)
    end

    def decorated_file
      @decorated_file ||= IoDecorator.new(file, mime_type, file_name)
    end

    # Return an object that knows how to access the content.
    def retriever
      @retriever ||= BrowseEverything::Retriever.new
    end

    # Fetch the content to a scratch file.  Returns the path to the
    # resulting file.  Subsequent calls return the same path.
    def downloaded_file_path
      target_dir = Plum::config[:upload_to]
      ext = File.extname(file_info['file_name'])
      base = File.basename(file_info['file_name'], ext)
      target = Dir::Tmpname.create([base, ext], target_dir) {}
      @downloaded_file_path ||= retriever.download(file_info, target)
    end

    # Remove our local scratch copy of the content.
    def cleanup_download
      File.delete(file.path)
    end
end
