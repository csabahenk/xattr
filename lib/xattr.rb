# Copyright (c) 2007 Daniel Harple <dharple@generalconsumption.org>

require "dl/import"

# Extended attributes extend the basic attributes of files and directories in
# the file system.  They are stored as name:data pairs associated with file
# system objects (files, directories, symlinks, etc). 
class Xattr
  VERSION = "0.1"
  
  module Raw_core # :nodoc:
    begin
      include DL::Importable # 1.8
    rescue NameError
      include DL::Importer   # 1.9
    end

    # actually, with gcc, these come from __SIZE_TYPE__ builtin macro
    def size_t
      "unsigned long"
    end

    def ssize_t
      "long"
    end
  end

  if RUBY_PLATFORM =~ /darwin/i
    # Raw access to *xattr() functions.
    module Raw # :nodoc:
      extend Raw_core
      # Don't follow symbolic links
      NOFOLLOW = 0x0001
      # set the value, fail if attr already exists
      CREATE = 0x0002
      # set the value, fail if attr does not exist
      REPLACE = 0x0004
      # Set this to bypass authorization checking (eg. if doing auth-related
      # work)
      NOSECURITY = 0x0008
      # Set this to bypass the default extended attribute file
      # (dot-underscore file)
      NODEFAULT = 0x0010
      # option for f/getxattr() and f/listxattr() to expose the HFS Compression
      # extended attributes
      SHOWCOMPRESSION  = 0x0020
      MAXNAMELEN = 127
      FINDERINFO_NAME = "com.apple.FinderInfo"
      RESOURCEFORK_NAME = "com.apple.ResourceFork"

      dlload "libSystem.dylib"

      extern "#{ssize_t} listxattr(const char *, void *, #{size_t}, int)"
      extern "#{ssize_t} getxattr(const char *, const char *, void *, #{size_t}, uint, int)"
      extern "int setxattr(const char *, const char *, void *, #{size_t}, uint, int)"
      extern "int removexattr(const char *, const char *, int)"
    end

    Unisys = Raw
  elsif RUBY_PLATFORM =~ /linux/i
    module Raw
      extend Raw_core
      # set the value, fail if attr already exists
      CREATE = 0x1
      # set the value, fail if attr does not exist
      REPLACE = 0x2

      dlload "libc.so.6"

      extern "#{ssize_t} listxattr(const char *, void *, #{size_t})"
      extern "#{ssize_t} getxattr(const char *, const char *, void *, #{size_t})"
      extern "int setxattr(const char *, const char *, void *, #{size_t}, int)"
      extern "int removexattr(const char *, const char *)"

      extern "#{ssize_t} llistxattr(const char *, void *, #{size_t})"
      extern "#{ssize_t} lgetxattr(const char *, const char *, void *, #{size_t})"
      extern "int lsetxattr(const char *, const char *, void *, #{size_t}, int)"
      extern "int lremovexattr(const char *, const char *)"
    end

    module Unisys
      # fake value to emulate Darwin API
      NOFOLLOW = 0x4

      module_function

      def removexattr(path, name, options)
        Raw.send(_mod(options) + "removexattr", path, name)
      end

      def listxattr(path, name, size, options)
        Raw.send(_mod(options) + "listxattr", path, name, size)
      end

      def getxattr(path, name, value, size, pos, options)
        Raw.send(_mod(options) + "getxattr", path, name, value, size)
      end

      def setxattr(path, name, value, size, pos, options)
        Raw.send(_mod(options) + "setxattr", path, name, value, size,
                 options & ~NOFOLLOW)
      end

      private_class_method

      def _mod(options)
        (options & NOFOLLOW).zero? ? "" : "l"
      end
    end
  else
    raise NotImplementedError, "your platform #{RUBY_PLATFORM} is not supported"
  end

  def initialize(path)
    @path = path
    @follow_symlinks = true
  end
  
  # Should we follow symlinks? #set, #get, #list, and #remove normally operate
  # on the target of the path if it is a symbolic link.  If #follow_symlinks
  # is false they will act on the link itself.
  attr_accessor :follow_symlinks
  
  # Return an Array of all attributes
  # 
  # See <tt>man 2 listxattr</tt> for a synopsis of errors that may be raised.
  def list
    options = _follow_symlinks_option()
    result = _allocate_result(Unisys.listxattr(@path, nil, 0, options))
    _error(Unisys.listxattr(@path, result, result.size, options))
    result.to_str.split("\000")
  end
  
  # Get an attribute
  #  
  # See <tt>man 2 getxattr</tt> for a synopsis of errors that may be raised.
  def get(attribute)
    options = _follow_symlinks_option()
    result = _allocate_result(Unisys.getxattr(@path, attribute, nil, 0, 0, options))
    _error(Unisys.getxattr(@path, attribute, result, result.size, 0, options))
    result.to_str
  end
      
  # Set an attribute (with options)
  #   
  # Valid key => value pairs for <tt>options:Hash</tt>:
  #         
  # * <tt>:create</tt> => +true+ || +false+: fail if the named attribute
  #   already exists. Default=+false+
  # * <tt>:replace</tt> => +true+ || +false+: fail if the named attribute does
  #   not exist. Default=+false+
  #   
  # Failure to specify <tt>:create</tt> or :+replace+ allows creation and
  # replacement.
  #  
  # See <tt>man 2 setxattr</tt> for a synopsis of errors that may be raised.
  def set(attribute, value, options={})
    opts = _follow_symlinks_option()
    opts |= Raw::CREATE if options[:create]
    opts |= Raw::REPLACE if options[:replace]
    value = value.to_s
    _error(Unisys.setxattr(@path, attribute, value, value.size, 0, opts))
    value
  end
  
  # Remove an attribute
  #  
  # See <tt>man 2 removexattr</tt> for a synopsis of errors that may be
  # raised.
  def remove(attribute)
    value = get(attribute)
    _error(Unisys.removexattr(@path, attribute, _follow_symlinks_option()))
    value
  end
  
private

  # All *xattr() functions return -1 on error
  if RUBY_VERSION < "1.9"
    def _error(return_code)
      raise SystemCallError.new(nil, DL.last_error) if return_code < 0
    end
  else
    def _error(return_code)
      raise SystemCallError.new(nil, Fiddle.last_error) if return_code < 0
    end
  end
  
  # Returns an int option to pass to a Unisys.*xattr() function
  def _follow_symlinks_option
    @follow_symlinks ? 0 : Unisys::NOFOLLOW
  end
  
  # Allocate a string to store results in
  if RUBY_VERSION < "1.9"
    def _allocate_result(len)
      _error(len)
      DL.malloc(len)
    end
  else
    def _allocate_result(len)
      _error(len)
      DL::CPtr.new(DL.malloc(len), len)
    end
  end
end
