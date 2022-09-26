module EffectiveIdvHelper

  def lockbox_encrypted_image_data(attachment)
    raise('expected an attachment') unless attachment && attachment.respond_to?(:attached?)

    encrypted_data = Base64.encode64(attachment.download)
    content_type = attachment.content_type.presence || 'image/jpeg'

    "data:#{content_type};base64,#{encrypted_data}"
  end

end
