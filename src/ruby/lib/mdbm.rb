#!/usr/bin/env ruby
# just a demo
# needs a new name, "mdbm" is taken by a gem already

require 'ffi'

class Mdbm
  extend FFI::Library
  ffi_lib 'libmdbm.so.4'

  # structs unused for now - needed at all? Or just use string calls?
  class Datum < FFI::Struct
    layout :string, :int
  end

  class KVpair < FFI::Struct
    layout :pointer, :pointer
  end

  # Create consts - FIXME, import the rest.
  # Does ruby have a mass *.h -> *.rb converter?
  MDBM_O_RDWR    = 0x00000002
  MDBM_O_CREAT   = 0x00000040

  # store flags
  MDBM_INSERT     = 0      # /**< Insert if key does not exist; fail if exists */
  MDBM_REPLACE    = 1      # /**< Update if key exists; insert if does not exist */
  MDBM_INSERT_DUP = 2      # /**< Insert new record (creates duplicate if key exists) */
  MDBM_MODIFY     = 3      # /**< Update if key exists; fail if does not exist */
  MDBM_STORE_MASK = 0x3    # /**< Mask for all store options */

  # extern MDBM* mdbm_open(const char *file, int flags, int mode, int psize, int presize);
  attach_function 'mdbm_open', [:string, :int, :int, :int, :int], :pointer

  # extern  void    mdbm_close(MDBM *db);
  attach_function 'mdbm_close', [:pointer], :void

  # extern char* mdbm_fetch_str(MDBM *db, const char *key);
  attach_function 'mdbm_fetch_str', [:pointer, :string], :string

  # extern int mdbm_delete_r(MDBM *db, MDBM_ITER* iter);
  attach_function 'mdbm_delete_r', [:pointer, :pointer], :int

  # extern int mdbm_store_str(MDBM *db, const char *key, const char *val, int flags);
  attach_function 'mdbm_store_str', [:pointer, :string, :string, :int], :int

  # extern int mdbm_delete_str(MDBM *db, const char *key);
  attach_function 'mdbm_delete_str', [:pointer, :string], :int

  def initialize(file, flags, mode, psize, presize)
  end

end

if __FILE__ == $0
  p = Mdbm::mdbm_open("/tmp/some.mdbm", (Mdbm::MDBM_O_RDWR|Mdbm::MDBM_O_CREAT), 0644, 128, 256)
  Mdbm::mdbm_store_str(p, "foo", "bar", Mdbm::MDBM_REPLACE)
  result = Mdbm::mdbm_fetch_str(p, "foo")
  puts "got result: '#{result}'"
  Mdbm::mdbm_delete_str(p, "foo")
  result = Mdbm::mdbm_fetch_str(p, "foo")
  puts "got result: '#{result}' after delete"
  Mdbm::mdbm_close(p)
end
