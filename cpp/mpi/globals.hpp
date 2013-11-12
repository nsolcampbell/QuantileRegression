#ifndef GLOBALS_HPP
#define GLOBALS_HPP

#include <ext/hash_map>
#include <ext/hash_set>
#include <utility>
#include <string>

#include <elemental.hpp>

/* MPI related global variables */
extern int mpi_rank;
extern int mpi_size;
const int ROOT=0;

/* Service related global variables */
extern int server_sockfd;

/* check if something is a directory */
static inline bool is_directory (const char* candidate) {
  struct stat s;
  return (0 == stat (candidate, &s) && (s.st_mode&S_IFDIR));
}

/* check if something is a file */
static inline bool is_file (const char* candidate) {
  struct stat s;
  return (0 == stat (candidate, &s) && (s.st_mode&S_IFREG));
}

/**
 * Remove ugly characters at the end.
 */
static inline void chomp (char* string) {
  for (int i=0; i<static_cast<int>(strlen(string)); ++i) { 
    if ('\n'==string[i] || '\r'==string[i]) {
      string[i] = '\0';
      return chomp (string);
    }
  }
}

//_GLIBCXX_BEGIN_NAMESPACE(__gnu_cxx)
namespace __gnu_cxx {
  template<> 
  struct hash<std::string> {
    size_t operator()(const std::string& x) const {
      return hash< const char* >()( x.c_str() );
    }
  };
}
//_GLIBCXX_END_NAMESPACE

typedef elem::Matrix<double> matrix_t;
typedef elem::DistMatrix<double> dist_matrix_t;

typedef __gnu_cxx::hash_map<std::string, matrix_t*> repl_dataset_map_t;
typedef __gnu_cxx::hash_map<std::string, dist_matrix_t*> dist_dataset_map_t;
extern repl_dataset_map_t repl_dataset_map;
extern dist_dataset_map_t dist_dataset_map;

extern char STDOUT[1024];
extern char STDERR[1024];

#endif // GLOBALS_HPP
