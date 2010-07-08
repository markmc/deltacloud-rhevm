
module DeltaCloud

  class AuthException < Exception
  end

  class BaseDriver

    def flavor(credentials, opts)
      flavors = flavors(credentials, opts)
      return flavors.first unless flavors.empty?
      nil
    end

    def flavors_by_architecture(credentials, architecture)
      flavors(credentials, :architecture => architecture)
    end


    def image(credentials, opts)
      images = images(credentials, opts)
      return images.first unless images.empty?
      nil
    end
    
    def instance(credentials, opts)
      instances = instances(credentials, opts)
      return instances.first unless instances.empty?
      nil
    end

    def volume(credentials, opts)
      volumes = volumes(credentials, opts)
      return volumes.first unless volumes.empty?
      nil
    end

    def snapshot(credentials, opts)
      snapshots = snapshots(credentials, opts)
      return snapshots.first unless snapshots.empty?
      nil
    end
  end

end