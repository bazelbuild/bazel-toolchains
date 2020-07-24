# Generated file, do not modify by hand
# Generated by 'rbe_autoconfig_autogen_ubuntu1604' rbe_autoconfig rule
"""Definitions to be used in rbe_repo attr of an rbe_autoconf rule  """
toolchain_config_spec0 = struct(config_repos = [], create_cc_configs = True, create_java_configs = True, env = {"ABI_LIBC_VERSION": "glibc_2.19", "ABI_VERSION": "clang", "BAZEL_COMPILER": "clang", "BAZEL_HOST_SYSTEM": "i686-unknown-linux-gnu", "BAZEL_TARGET_CPU": "k8", "BAZEL_TARGET_LIBC": "glibc_2.19", "BAZEL_TARGET_SYSTEM": "x86_64-unknown-linux-gnu", "CC": "clang", "CC_TOOLCHAIN_NAME": "linux_gnu_x86"}, java_home = "/usr/lib/jvm/java-8-openjdk-amd64", name = "9.0.0")
toolchain_config_spec1 = struct(config_repos = [], create_cc_configs = True, create_java_configs = True, env = {"ABI_LIBC_VERSION": "glibc_2.19", "ABI_VERSION": "clang", "BAZEL_COMPILER": "clang", "BAZEL_HOST_SYSTEM": "i686-unknown-linux-gnu", "BAZEL_TARGET_CPU": "k8", "BAZEL_TARGET_LIBC": "glibc_2.19", "BAZEL_TARGET_SYSTEM": "x86_64-unknown-linux-gnu", "CC": "clang", "CC_TOOLCHAIN_NAME": "linux_gnu_x86"}, java_home = "/usr/lib/jvm/java-8-openjdk-amd64", name = "8.0.0")
toolchain_config_spec2 = struct(config_repos = [], create_cc_configs = True, create_java_configs = True, env = {"ABI_LIBC_VERSION": "glibc_2.19", "ABI_VERSION": "clang", "BAZEL_COMPILER": "clang", "BAZEL_HOST_SYSTEM": "i686-unknown-linux-gnu", "BAZEL_TARGET_CPU": "k8", "BAZEL_TARGET_LIBC": "glibc_2.19", "BAZEL_TARGET_SYSTEM": "x86_64-unknown-linux-gnu", "CC": "clang", "CC_TOOLCHAIN_NAME": "linux_gnu_x86"}, java_home = "/usr/lib/jvm/java-8-openjdk-amd64", name = "10.0.0")
toolchain_config_spec3 = struct(config_repos = [], create_cc_configs = True, create_java_configs = True, env = {"ABI_LIBC_VERSION": "glibc_2.19", "ABI_VERSION": "clang", "BAZEL_COMPILER": "clang", "BAZEL_HOST_SYSTEM": "i686-unknown-linux-gnu", "BAZEL_TARGET_CPU": "k8", "BAZEL_TARGET_LIBC": "glibc_2.19", "BAZEL_TARGET_SYSTEM": "x86_64-unknown-linux-gnu", "CC": "clang", "CC_TOOLCHAIN_NAME": "linux_gnu_x86"}, java_home = "/usr/lib/jvm/java-8-openjdk-amd64", name = "11.0.0")
_TOOLCHAIN_CONFIG_SPECS = [toolchain_config_spec0, toolchain_config_spec1, toolchain_config_spec2, toolchain_config_spec3]
_BAZEL_TO_CONFIG_SPEC_NAMES = {"0.20.0": ["8.0.0"], "0.21.0": ["8.0.0"], "0.22.0": ["8.0.0", "9.0.0"], "0.23.0": ["8.0.0", "9.0.0"], "0.23.1": ["8.0.0", "9.0.0"], "0.23.2": ["9.0.0"], "0.24.0": ["9.0.0"], "0.24.1": ["9.0.0"], "0.25.0": ["9.0.0"], "0.25.1": ["9.0.0"], "0.25.2": ["9.0.0"], "0.26.0": ["9.0.0"], "0.26.1": ["9.0.0"], "0.27.0": ["9.0.0"], "0.27.1": ["9.0.0"], "0.28.0": ["9.0.0"], "0.28.1": ["9.0.0"], "0.29.0": ["9.0.0"], "0.29.1": ["9.0.0", "10.0.0"], "1.0.0": ["9.0.0", "10.0.0"], "1.0.1": ["10.0.0"], "1.1.0": ["10.0.0"], "1.2.0": ["10.0.0"], "1.2.1": ["10.0.0"], "2.0.0": ["10.0.0"], "2.1.0": ["10.0.0"], "2.1.1": ["10.0.0", "11.0.0"], "2.2.0": ["11.0.0"], "3.0.0": ["11.0.0"], "3.1.0": ["11.0.0"], "3.2.0": ["11.0.0"], "3.3.0": ["11.0.0"], "3.3.1": ["11.0.0"], "3.4.1": ["11.0.0"]}
LATEST = "sha256:78d89fbe50fdedf2e103b222f9fb970e30fc25be9001e9e6d425677964ef3bca"
CONTAINER_TO_CONFIG_SPEC_NAMES = {"sha256:01b134af5416df3d240f2028d2a1d52b5a27cf24b12b62de82e635bc8718caf0": ["11.0.0"], "sha256:06f8f8e9f97daa1c15466536dc2a7ae6641d16962d7b58a393af8060e460f571": ["10.0.0"], "sha256:09fbb5438d51626dabfe096db381b733af6ed5fd59f07f0a311840598f78019c": ["9.0.0"], "sha256:1062b3c9002e6c09e31d3463fc5c24b0d2212f706733404918e18cff8f66dc5c": ["10.0.0"], "sha256:169876b30f3f8ec0430720d319c7eb8a66268501ca62e2acd4e0e7867d5883df": ["11.0.0"], "sha256:1a8ed713f40267bb51fe17de012fa631a20c52df818ccb317aaed2ee068dfc61": ["11.0.0"], "sha256:1ab40405810effefa0b2f45824d6d608634ccddbf06366760c341ef6fbead011": ["10.0.0"], "sha256:1e7bf60f191f6221b010f9338b57936d378baa7b6488dcf5235e2939d62fb9ec": ["10.0.0"], "sha256:29dc13bace3faca2b42e8dbd32c314bed960c313b9e144575eee58338eead9a8": ["10.0.0"], "sha256:2b73cbf679cbf11ed1f782511d3eb8ec7d69049b5947f503c190e9352fd27289": ["9.0.0"], "sha256:2c925275fb30478602cd53651eeaaf015f964ad1b84d3947ed710802f054035b": ["9.0.0"], "sha256:3c104745837918f854415f78f63afe7f680f0876dda837058c38e6eee54e253c": ["10.0.0"], "sha256:3e98e2e1233de1aed4ed7d7e05450a3f75b8c8d6f6bf53f1b390b5131c790f6f": ["9.0.0"], "sha256:4638ee6192eb79354f25d89f190331113997ba1713d7626023b693470dfc52ec": ["11.0.0"], "sha256:4818e1254bb6c85f4ea1ca7a6e0c705f7ed6944809704df88137fa535d681be5": ["11.0.0"], "sha256:4bfd33aa9ce73e28718385b8c01608a79bc6546906f01cf9329311cace1766a1": ["10.0.0"], "sha256:5464e3e83dc656fc6e4eae6a01f5c2645f1f7e95854b3802b85e86484132d90e": ["11.0.0"], "sha256:57fbf17cb0d43fb7a00b4e0476750643cb80377e5c38b2e28490d6c69ad8fa2d": ["10.0.0"], "sha256:5e750dd878df9fcf4e185c6f52b9826090f6e532b097f286913a428290622332": ["11.0.0"], "sha256:677c1317f14c6fd5eba2fd8ec645bfdc5119f64b3e5e944e13c89e0525cc8ad1": ["9.0.0"], "sha256:69c9f1652941d64a46f6f7358a44c1718f25caa5cb1ced4a58ccc5281cd183b5": ["9.0.0"], "sha256:6ad1d0883742bfd30eba81e292c135b95067a6706f3587498374a083b7073cb9": ["10.0.0"], "sha256:78d89fbe50fdedf2e103b222f9fb970e30fc25be9001e9e6d425677964ef3bca": ["11.0.0"], "sha256:823aa3cc811b40d8cd7a8df529553ceb8a49bf2adffcebedc4e49dbd8daafca0": ["9.0.0"], "sha256:87d0fa2c56558f2f0d05116e6142b29d9ee509776be5fa9794a57f281b75b14e": ["10.0.0"], "sha256:87e1bb4a47ade8ad4db467a2339bd0081fcf485ec02bcfc3b30309280b38d14b": ["10.0.0"], "sha256:87fe00c5c4d0e64ab3830f743e686716f49569dadb49f1b1b09966c1b36e153c": ["8.0.0"], "sha256:91739a2a3979753111d563fc0202e10e9cd8b9b2ce9552d6a7213892cfe2deb7": ["10.0.0"], "sha256:93f7e127196b9b653d39830c50f8b05d49ef6fd8739a9b5b8ab16e1df5399e50": ["10.0.0"], "sha256:94d7d8552902d228c32c8c148cc13f0effc2b4837757a6e95b73fdc5c5e4b07b": ["9.0.0"], "sha256:98cd34f400a696c0409a3aa0411923b7198aced800a84f23b31f883f8bf407e7": ["9.0.0"], "sha256:9bd8ba020af33edb5f11eff0af2f63b3bcb168cd6566d7b27c6685e717787928": ["8.0.0"], "sha256:9d3104c820537dbf975c78048ddbe71d3f82515cf92b1106ddc552292c187511": ["10.0.0"], "sha256:ac36d37616b044ee77813fc7cd36607a6dc43c65357f3e2ca39f3ad723e426f6": ["10.0.0"], "sha256:aec4629f0856fef325ad03e6b593ccc52eff3328ced6cac351667b85eec48f88": ["9.0.0"], "sha256:b4dad0bfc4951d619229ab15343a311f2415a16ef83bcaa55b44f4e2bf1cf635": ["11.0.0"], "sha256:b516a2d69537cb40a7c6a7d92d0008abb29fba8725243772bdaf2c83f1be2272": ["11.0.0"], "sha256:bc6a2ad47b24d01a73da315dd288a560037c51a95cc77abb837b26fef1408798": ["9.0.0"], "sha256:d4edc52e8c0171905fc43773846b84d8d6ab4f75354986b82f9eddb6563bbe0f": ["10.0.0"], "sha256:d7bea5c70932edfddafda2da51814a17712585df319bbc11b4d17f662aec6c46": ["9.0.0"], "sha256:da0f21c71abce3bbb92c3a0c44c3737f007a82b60f8bd2930abc55fe64fc2729": ["9.0.0"], "sha256:ec8710e636220c090b84f80a657a61b548dc94d4e3df5e3c42ca048ca74bcfb0": ["10.0.0"], "sha256:ef6ab043a2b570fbfb14121c78248f1ba496fab78df017acbb121fcd01731e74": ["11.0.0"], "sha256:f3120a030a19d67626ababdac79cc787e699a1aa924081431285118f87e7b375": ["8.0.0"], "sha256:f5d13baa00009baffb87194cd52cef0165b52d37477093ff72410114664f4380": ["9.0.0"], "sha256:f6fb11fbdc2965f7fef1bcc81565e5bc41a6a91d5ee7a375dbb3a8ea130de5f1": ["9.0.0"], "sha256:fbd499b53a377fe2c6c5e65c33bdecd9393871e19a64eaf785fb6491f31849d3": ["9.0.0"], "sha256:fd5690d000da5759121f28ccbc19ebb4545841d816bbf6a72de482cf3e7ce491": ["10.0.0"]}
_DEFAULT_TOOLCHAIN_CONFIG_SPEC = toolchain_config_spec0
TOOLCHAIN_CONFIG_AUTOGEN_SPEC = struct(
    bazel_to_config_spec_names_map = _BAZEL_TO_CONFIG_SPEC_NAMES,
    container_to_config_spec_names_map = CONTAINER_TO_CONFIG_SPEC_NAMES,
    default_toolchain_config_spec = _DEFAULT_TOOLCHAIN_CONFIG_SPEC,
    latest_container = LATEST,
    toolchain_config_specs = _TOOLCHAIN_CONFIG_SPECS,
)
