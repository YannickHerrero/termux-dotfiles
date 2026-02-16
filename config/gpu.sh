#!/data/data/com.termux/files/usr/bin/bash
# ============== GPU ACCELERATION CONFIG ==============
# Mesa Zink (OpenGL -> Vulkan) + Turnip (Adreno) driver stack
#
# Sourced by start-desktop.sh and optionally from ~/.bashrc
# On non-Adreno devices, Zink falls back to swrast (software Vulkan)

# Disable OpenGL error checking for performance
export MESA_NO_ERROR=1

# Advertise OpenGL 4.6 / GLES 3.2 support
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLES_VERSION_OVERRIDE=3.2

# Force Mesa to use the Zink Gallium driver (OpenGL over Vulkan)
export GALLIUM_DRIVER=zink
export MESA_LOADER_DRIVER_OVERRIDE=zink

# Turnip-specific: skip conformance checks for performance
export TU_DEBUG=noconform

# Immediate presentation mode (no vsync)
export MESA_VK_WSI_PRESENT_MODE=immediate

# Lazy descriptor allocation for Zink performance
export ZINK_DESCRIPTORS=lazy
