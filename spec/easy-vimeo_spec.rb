require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

VIDEO_RESPONSE_HASH = { 'video' => [{ 'title' => 'Ma video', 'description' => 'Great description', 'caption' => 'Great caption', 'privacy' => 'nobody', 'thumbnails' => { 'thumbnail' => ['http://first_thumb.jpg'] }, 'tags' => { 'tag' => ['cool', 'great'] }, 'is_transcoding' => '0', 'is_uploading' => '0' }] }

describe "EasyVimeo" do

  def video_init(options = {})
    @api_key = "pipo"
    @secret_key = "molo"
    @video = Vimeo::Easy.new :api_key => @api_key, :secret_key => @secret_key, :auth_token => options[:auth_token]
  end
  
  def video_load
    @video.vimeo_video.should_receive(:get_info).and_return(VIDEO_RESPONSE_HASH)
    @video.video_id = 9999999
    @video.reload
  end

  it "should not initialize without secret_key & api_key" do
    lambda { Vimeo::Easy.new }.should raise_error
  end
  
  it "should initialize with secret_key & api_key and set default attributes" do
    video_init
    
    @video.api_key.should == @api_key
    @video.privacy.should == :anybody
    
    @video.vimeo_upload.should be_a(Vimeo::Advanced::Upload)
    @video.vimeo_video.should be_a(Vimeo::Advanced::Video)
    
    @video.should be_new_record
  end
  
  it "should not accept bad privacy type" do
    video_init
    
    lambda { @video.privacy = :pipo }.should raise_error
  end
  
  it "should not reload the video without video_id" do
    video_init
    
    lambda { @video.reload }.should raise_error
  end
  
  it "should reload the video with video_id" do
    video_init
    video_load
    
    @video.title.should == 'Ma video'
    @video.description.should == 'Great description'
    @video.privacy.should == :nobody
    @video.tags.should == 'cool, great'
    @video.thumbnail.should == 'http://first_thumb.jpg'
    
    @video.should be_available
    @video.should_not be_new_record
  end
  
  it "should not be able to save with a file if video is already uploaded" do
    video_init(:auth_token => "pipo")
    video_load
    
    @video.file = '/tmp/pipo'
    lambda { @video.save }.should raise_error
  end
  
  it 'should not be able to save a video without auth_token or video_id' do
    video_init
    video_load
    
    lambda { @video.save }.should raise_error
    
    video_init(:auth_token => "pipo")
    lambda { @video.save }.should raise_error
  end
  
  it 'should be able to save a video' do
    video_init(:auth_token => "pipo")
    video_load
    
    @video.vimeo_video.should_receive(:set_privacy).and_return(true)
    @video.vimeo_video.should_receive(:set_description).and_return(true)
    @video.vimeo_video.should_receive(:set_title).and_return(true)
    
    @video.save.should == true
  end
  
  it 'should be able to save a video with a file' do
    video_init(:auth_token => "pipo")
    
    @video.file = '/tmp/pipo'
    
    File.should_receive(:exists?).with('/tmp/pipo').and_return(true)
    @video.vimeo_upload.should_receive(:get_ticket).and_return({ "ticket" => { "id" => "123456", "endpoint" => "654321" } })
    @video.vimeo_upload.should_receive(:upload).with("pipo", "/tmp/pipo", "123456", "654321").and_return("MD5")
    
    @video.vimeo_upload.should_receive(:confirm).with("pipo", "123456", "MD5").and_return({ "ticket" => { "video_id" => "99999" } })
    
    @video.vimeo_video.should_receive(:set_privacy).and_return(true)
    @video.vimeo_video.should_not_receive(:set_description)
    @video.vimeo_video.should_not_receive(:set_title)
    
    @video.save.should == true
    @video.video_id.should == "99999"
    @video.should_not be_new_record
  end
  
  it 'should be able to find a video with a Vimeo ID' do
    Vimeo::Easy.should_receive(:new).with(:toto => "pipo", :video_id => 123456).and_return(true)
    Vimeo::Easy.find(123456, :toto => "pipo")
  end
end
