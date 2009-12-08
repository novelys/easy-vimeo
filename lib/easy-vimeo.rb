require "vimeo"

module Vimeo
  class Easy
    
    UPLOAD_URL = "http://vimeo.com/services/upload"
    PRIVACY_MODES = [:anybody, :contacts, :nobody, :users]
    
    private
    attr_writer :thumbnail
    
    public
    attr_accessor :vimeo_upload, :api_key, :auth_token, :vimeo_video, :video_id, :description, :title, :file
    attr_reader :privacy, :thumbnail, :tags
    
    # This method initializes a new instance.
    # You should pass an options Hash containing :
    # :api_key # The API key of your account
    # :secret_key # The secret key
    # :auth_token # (optional) The authorization token, needed to upload a video
    # :video_id # (optional) The ID of the video, if it is already uploaded
    #
    def initialize(options = {})
      raise "You must pass :api_key and :secret_key at least to initialize the class." unless options[:api_key] && options[:secret_key]
      self.api_key = options[:api_key]
      self.auth_token = options[:auth_token]
      self.video_id = options[:video_id]
      self.vimeo_upload = Vimeo::Advanced::Upload.new(self.api_key, options[:secret_key])
      self.vimeo_video = Vimeo::Advanced::Video.new(self.api_key, options[:secret_key])
      self.privacy = :anybody
      @new_record = true
      
      if self.video_id
        self.reload
      end
    end
    
    def self.find(video_id, options = {})
      self.new(options.merge(:video_id => video_id))
    end
    
    def new_record?
      @new_record
    end
    
    def tags=(tags)
      return tags if self.tags && tags.split(',').map(&:strip).sort == self.tags.split(',').map(&:strip).sort # Do not change attributes if the tags are the same
      @tags = @new_tags = tags
    end
    
    def privacy=(mode)
      raise "Privacy mode not allowed, should be one of : #{PRIVACY_MODES.join(', ')}." unless PRIVACY_MODES.include?(mode)
      @privacy = mode
    end
    
    # This method destroys the Vimeo Video
    #
    def destroy
      check_presence_of :video_id, :auth_token
      
      self.vimeo_video.delete(self.auth_token, self.video_id)
      true
    rescue
      false
    end
    
    def available?
      !!@availability
    end
    
    def reload
      check_presence_of :video_id

      begin
        video_response = self.vimeo_video.get_info(self.video_id)['video'][0]
        self.title = video_response['title']
        self.description = video_response['description']
        self.privacy = video_response['privacy'].to_sym
        self.thumbnail = (video_response['thumbnails']['thumbnail'].first rescue nil)
        @tags = (video_response['tags']['tag'].join(', ') rescue nil)
        @availability = video_response['is_transcoding'].to_i.zero? && video_response['is_uploading'].to_i.zero?
        @new_record = false

        true
      rescue
        false
      end
    end
    
    def save
      if self.file
        raise "Cannot upload a video file on an existing video! Create a new instance instead." unless new_record?
        post_video!
      end
      check_presence_of :video_id, :auth_token
      
      begin
        self.vimeo_video.set_privacy(self.auth_token, self.video_id, self.privacy.to_s)
        self.vimeo_video.set_description(self.auth_token, self.video_id, self.description) if self.description
        self.vimeo_video.set_title(self.auth_token, self.video_id, self.title) if self.title
        if @new_tags
          self.vimeo_video.clear_tags(self.auth_token, self.video_id)
          self.vimeo_video.add_tags(self.auth_token, self.video_id, self.tags)
          @new_tags = nil
        end
      rescue
        return false
      end
      
      @new_record = false
      @file = nil
      true
    end
    
    private
    def check_presence_of(*attributes)
      raise "You must set #{attributes.join(' and ')} to use this method." unless attributes.all? { |a| self.send(a) != nil }
    end
    
    # This method post a new video
    # The parameter is the video filename
    # After uploading, the video_id is set to the id of the new uploaded video
    #
    def post_video!
      raise "You must set auth_token to use this method." unless self.auth_token
      raise "File does not exist (#{self.file})." unless File.exists?(self.file)
      
      ticket = self.vimeo_upload.get_ticket(self.auth_token)["ticket"]
      ticket_id = ticket["id"]
      
      end_point = ticket["endpoint"]
      json_manifest = self.vimeo_upload.upload(self.auth_token, self.file, ticket_id, end_point)
            
      request_confirm = self.vimeo_upload.confirm(self.auth_token, ticket_id, json_manifest)
            
      self.video_id = request_confirm["ticket"]["video_id"]
    rescue # FIXME : that's bad to rescue all exceptions, but for now, throw false.
      false
    end
  end
end
