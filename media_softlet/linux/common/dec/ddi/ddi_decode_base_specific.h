/*
* Copyright (c) 2022, Intel Corporation
*
* Permission is hereby granted, free of charge, to any person obtaining a
* copy of this software and associated documentation files (the "Software"),
* to deal in the Software without restriction, including without limitation
* the rights to use, copy, modify, merge, publish, distribute, sublicense,
* and/or sell copies of the Software, and to permit persons to whom the
* Software is furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included
* in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
* OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
* OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
* ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
* OTHER DEALINGS IN THE SOFTWARE.
*/
//!
//! \file     ddi_decode_base_specific.h
//! \brief    Defines base class for DDI media decode.
//!

#ifndef _DDI_DECODE_BASE_SPECIFIC_H_
#define _DDI_DECODE_BASE_SPECIFIC_H_

#include <stdint.h>
#include <va/va.h>
#include "media_ddi_base.h"
#include "decode_pipeline_adapter.h"
#include "media_libva_decoder.h"
#include "media_capstable_specific.h"

//namespace decode
//{

//!
//! \class  DdiDecodeBase
//! \brief  Ddi decode base
//!
class DdiDecodeBase : public DdiMediaBase
{
public:
    //!
    //! \brief Constructor
    //!
    DdiDecodeBase();

    //!
    //! \brief Destructor
    //!
    virtual ~DdiDecodeBase()
    {
        MOS_FreeMemory(m_ddiDecodeAttr);
        m_ddiDecodeAttr = nullptr;
        MOS_Delete(m_codechalSettings);
        m_codechalSettings = nullptr;
#ifdef _DECODE_PROCESSING_SUPPORTED
        MOS_FreeMemory(m_procBuf);
        m_procBuf = nullptr;
#endif
    }

    //! \brief    the type conversion to get the DDI_DECODE_CONTEXT
    inline operator DDI_DECODE_CONTEXT *()
    {
        return m_decodeCtx;
    }

    //!
    //! \brief    Free the allocated resource related with the decode context
    //! \details  Free the private resource related with the decode context.
    //!           For example: DecodeParams, CodecHal and so on.
    //!
    //! \param    [in] ctx
    //!           VADriverContextP
    //!
    virtual void DestroyContext(VADriverContextP ctx) = 0;

    //!
    //! \brief    Get ready to decoding process for a target surface
    //! \details  It begins the decoding process for a specified target surface
    //!
    //! \param    [in] ctx
    //!           VADriverContextP
    //! \param    [in] context
    //!           Already created context for the decoding process
    //! \param    [in] renderTarget
    //!           Specified target surface
    //!
    //! \return   VAStatus
    //!           VA_STATUS_SUCCESS if success, else fail reason
    //!
    virtual VAStatus BeginPicture(
        VADriverContextP ctx,
        VAContextID      context,
        VASurfaceID      renderTarget);

    //!
    //! \brief    Send required buffers to decoding process
    //! \details  It sends needed buffers by the decoding to the driver
    //!
    //! \param    [in] ctx
    //!           VADriverContextP
    //! \param    [in] context
    //!           Already created context for the decoding process
    //! \param    [in] buffers
    //!           Pointer to the buffer array
    //! \param    [in] numBuffers
    //!           Number of buffers in above array
    //!
    //! \return   VAStatus
    //!           VA_STATUS_SUCCESS if success, else fail reason
    //!
    virtual VAStatus RenderPicture(
        VADriverContextP ctx,
        VAContextID      context,
        VABufferID       *buffers,
        int32_t          numBuffers) = 0;

    //!
    //! \brief    Init Params setting of EndPicture Function
    //! \details  The function is used to init EndPicture params
    //!
    //! \param    [in] ctx
    //!           VADriverContextP
    //! \param    [in] context
    //!           Already created context for the process
    //!
    //! \return   VAStatus
    //!           VA_STATUS_SUCCESS if success
    //!
    virtual VAStatus InitDecodeParams(
        VADriverContextP ctx,
        VAContextID      context);

    //!
    //! \brief    Get decode format
    //! \details  The function is used to get decode format
    //!
    //! \return   MOS_FORMAT 
    //!           VA_STATUS_SUCCESS if success
    //!
    virtual MOS_FORMAT GetFormat();

    //!
    //! \brief    Set common decode param setting for each codec
    //! \details  Set common decode param setting for each decode class
    //!
    //! \return   VAStatus 
    //!           VA_STATUS_SUCCESS if success
    //!
    virtual VAStatus SetDecodeParams() = 0;

    //!
    //! \brief    Make the end of rendering for a picture
    //! \details  The driver will flush/submit the decoding processing.
    //!           This call is non-blocking. The app can start another
    //!           Begin/Render/End sequence on a different render target
    //!
    //! \param    [in] ctx
    //!           VADriverContextP
    //! \param    [in] context
    //!           Already created context for the process
    //!
    //! \return   VAStatus
    //!           VA_STATUS_SUCCESS if success, else fail reason
    //!
    virtual VAStatus EndPicture(
        VADriverContextP ctx,
        VAContextID      context);

    //!
    //! \brief    the first step of Initializing internal structure of DdiDecodeBase
    //! \details  Initialize and allocate the internal structur of DdiDecodeBase. This
    //!           is the first step.
    //! \param    [in] linuxConfAttr
    //!           the config attr related with the linux caps
    //! \return   VAStatus
    //!           VA_STATUS_SUCCESS if success, else fail reason

    VAStatus BasicInit(ConfigLinux *configItem);
    //!
    //! \brief    the second step of Initializing internal structure of DdiDecodeBase
    //! \details  Initialize the internal structure of DdiDecodeBase base on
    //!           input width/height. It is step two
    //!
    //! \param    [in] picWidth
    //!           int32_t
    //! \param    [in] picHeight
    //!           int32_t
    //!
    virtual void ContextInit(
        int32_t picWidth,
        int32_t picHeight) = 0;

    //!
    //! \brief    Initialize the back-end CodecHal of DdiDecodeBase
    //! \details  Initialize the back-end CodecHal of DdiDecodeBase base on
    //!           the codec attribute. This is the third step of DdiMediDecode context
    //!           initialiazation.
    //!
    //! \param    [in] mediaCtx
    //!           DDI_MEDIA_CONTEXT * type
    //! \param    [in] ptr
    //!           extra data
    //! \return   VAStatus
    //!           VA_STATUS_SUCCESS if success, else fail reason
    virtual VAStatus CodecHalInit(
        DDI_MEDIA_CONTEXT *mediaCtx,
        void              *ptr) = 0;

    //!
    //! \brief    Get bit stream buffer index 
    //! \details  Get bit stream buffer index
    //!
    //! \param    [in] bufMgr
    //!           DDI_CODEC_COM_BUFFER_MGR *bufMgr
    //! \param    [in] buf
    //!           DDI_MEDIA_BUFFER *buf
    //! \return   i
    //!           buffer index
    virtual int32_t GetBitstreamBufIndexFromBuffer(
        DDI_CODEC_COM_BUFFER_MGR *bufMgr,
        DDI_MEDIA_BUFFER         *buf);

    //!
    //! \brief    Allocate slice control buffer
    //! \details  Allocate slice control buffer
    //!
    //! \param    [in] buf
    //!           DDI_MEDIA_BUFFER *buf
    //! \return   VAStatus
    //!
    virtual VAStatus AllocSliceControlBuffer(
        DDI_MEDIA_BUFFER *buf) = 0;

    //!
    //! \brief    Allocate Bs buffer
    //! \details  Allocate Bs buffer
    //!
    //! \param    [in] bufMgr
    //!           DDI_CODEC_COM_BUFFER_MGR    *bufMgr
    //! \param    [in] buf
    //!           DDI_MEDIA_BUFFER            *buf
    //! \return   VAStatus
    //!
    virtual VAStatus AllocBsBuffer(
        DDI_CODEC_COM_BUFFER_MGR *bufMgr,
        DDI_MEDIA_BUFFER         *buf);

    //! 
    //! \brief    Get Picture parameter size 
    //! \details  Get Picture parameter size for each decoder 
    //! 
    //! \param    [in] bufMgr 
    //!        DDI_CODEC_COM_BUFFER_MGR    *bufMgr 
    //! \return   uint8_t* 
    //!
     virtual uint8_t* GetPicParamBuf(
         DDI_CODEC_COM_BUFFER_MGR *bufMgr)
         {
             return (uint8_t*)bufMgr;
         }

    //! 
    //! \brief    Create buffer in ddi decode context 
    //! \details  Create related decode buffer in ddi decode base class 
    //! 
    //! \param    [in] type 
    //!           VABufferType type
    //! \param    [in] size 
    //!           uint32_t size
    //! \param    [in] numElements 
    //!           uint32_t numElements
    //! \param    [in] data 
    //!           void data
    //! \param    [in] bufId 
    //!           VABufferID bufId
    //!
    virtual VAStatus CreateBuffer(
        VABufferType type,
        uint32_t     size,
        uint32_t     numElements,
        void         *data,
        VABufferID   *bufId);
    
    //!
    //! \brief    if it is  range extention
    //!
    //! \return   true or false
    //!
    virtual bool IsRextProfile()
    {
        return false;
    }

    //! \brief    Combine the Bitstream Before decoding execution
    //! \details  Help to refine and combine the decoded input bitstream if
    //!           required. It is decided by the flag of IsSliceOverSize.
    //! \param    [in] mediaCtx
    //!           DDI_MEDIA_CONTEXT * type
    //!
    //! \return   VAStatus
    //!           VA_STATUS_SUCCESS if success, else fail reason
    //!
    VAStatus DecodeCombineBitstream(DDI_MEDIA_CONTEXT *mediaCtx);

    //!
    //! \brief    Check if the resolution is valid for a given decode codec mode
    //!
    //! \param    [in] codecMode
    //!           Specify the codec mode
    //!
    //! \param    [in] profile
    //!           VA profile
    //!
    //! \param    [in] width
    //!           Specify the width for checking
    //!
    //! \param    [in] height
    //!           Specify the height for checking
    //!
    //! \return   VAStatus
    //!           VA_STATUS_SUCCESS if the resolution is supported
    //!           VA_STATUS_ERROR_RESOLUTION_NOT_SUPPORTED if the resolution isn't valid
    //!
    virtual VAStatus CheckDecodeResolution(
            int32_t   codecMode,
            VAProfile profile,
            uint32_t  width,
            uint32_t  height) = 0;

    //!
    //! \brief    Return internal decode mode for given profile
    //!
    //! \param    [in] profile
    //!           Specify the VAProfile
    //!
    //! \return   Codehal mode: decode codec mode
    //!
    virtual CODECHAL_MODE GetDecodeCodecMode(VAProfile profile) = 0;

    //! \brief    the referred DDI_DECODE_CONTEXT object
    //! \details  This is allocated when creating one new instance. As it is
    //!           referred by other component, it should be free explicitly
    //!           outside of the instance.
    DDI_DECODE_CONTEXT *m_decodeCtx = nullptr;

protected:
    //! \brief    the decode_config_attr related with Decode_CONTEXT
    ConfigLinux *m_ddiDecodeAttr = nullptr;

    //! \brief    decoded picture buffer flag
    bool m_withDpb = true;

    //!
    //! \brief    return the Buffer offset for sliceGroup
    //! \details  return the Base  offset for one given slice_data buffer.
    //!           It can be applied under the following two scenarios:
    //!           Multiple slice parameters are included in one slice_param_buf
    //!           Only one slice parameter is in one slice_param_buf.
    //!
    //! \param    [in] sliceGroup
    //!           the index of slice_parameter group
    //!
    //! \return   return the base offset
    //!
    uint32_t GetBsBufOffset(int32_t sliceGroup);

    //! \brief    Parse the processing buffer if needed.
    //! \details  Helps to parse the Video-post processing buffer for Decoding
    //!
    //! \param    [in] mediaCtx
    //!           DDI_MEDIA_CONTEXT * type
    //! \param    [in] bufAddr
    //!           the address of passed buf
    //!
    //! \return   VAStatus
    //!           VA_STATUS_SUCCESS if success, else fail reason
    //!
    VAStatus ParseProcessingBuffer(
        DDI_MEDIA_CONTEXT *mediaCtx,
        void              *bufAddr);

    //!
    //! \brief    Create the back-end CodecHal of DdiDecodeBase
    //! \details  Create the back-end CodecHal of DdiDecodeBase base on
    //!           the codec attribute. This is one common function, which is called by CreateCodecHal.
    //!
    //! \param    [in] mediaCtx
    //!           DDI_MEDIA_CONTEXT * type
    //! \param    [in] ptr
    //!           extra data
    //! \param    [in] standardInfo
    //!           CODECHAL_STANDARD_INFO *
    //!
    //! \return   VAStatus
    //!           VA_STATUS_SUCCESS if success, else fail reason

    VAStatus CreateCodecHal(
        DDI_MEDIA_CONTEXT       *mediaCtx,
        void                    *ptr,
        _CODECHAL_STANDARD_INFO *standardInfo);

    //!
    //! \brief    Get dummy reference from DPB
    //! \details  Get dummy reference from DPB for error concealment
    //!
    //! \param    [in] decodeCtx
    //!           DDI_DECODE_CONTEXT * type
    //!
    //! \return   void
    void GetDummyReferenceFromDPB(
        DDI_DECODE_CONTEXT *decodeCtx);

    //!
    //! \brief    Report decode mode
    //! \details  Report decode mode to UFKEY_INTERNAL
    //!
    //! \param    [in] wMode
    //!           CODECHAL_MODE
    //!
    //! \return   void
    void ReportDecodeMode(
        uint16_t wMode);

    //! \brief    Use EU path to do the scaling
    //! \details  When VD+SFC are not supported, it will call into VPhal to do scaling
    //!
    //! \param    [in] ctx
    //!           VADriverContextP * type
    //! \param    [in] context
    //!           Already created context for the process
    //!
    //! \return   VAStatus
    //!           VA_STATUS_SUCCESS if success, else fail reason
    VAStatus ExtraDownScaling(
            VADriverContextP ctx,
            VAContextID      context);

    //! \brief    Init dummy reference
    //! \details  Init dummy reference for decode
    //!
    //! \param    [in/out] decoder
    //!           Codechal decoder
    //!
    //! \return   VAStatus
    //!           VA_STATUS_SUCCESS if success, else fail reason
    VAStatus InitDummyReference(CodechalDecode& decoder);

    //! \brief    Init dummy reference
    //! \details  Init dummy reference for decode
    //!
    //! \param    [in/out] decoder
    //!           DecodePipelineAdapter decoder
    //!
    //! \return   VAStatus
    //!           VA_STATUS_SUCCESS if success, else fail reason
    VAStatus InitDummyReference(DecodePipelineAdapter& decoder);

    //! \brief  the type of decode base class
    MOS_SURFACE           m_destSurface;          //!<Destination Surface structure
    uint32_t              m_groupIndex;           //!<global Group
    uint16_t              m_picWidthInMB;         //!<Picture Width in MB width count
    uint16_t              m_picHeightInMB;        //!<Picture Height in MB height count
    uint32_t              m_width;                //!<Picture Width
    uint32_t              m_height;               //!<Picture Height
    bool                  m_streamOutEnabled;     //!<Stream Out enable flag
    uint32_t              m_sliceParamBufNum;     //!<Slice parameter Buffer Number
    uint32_t              m_sliceCtrlBufNum;      //!<Slice control Buffer Number
    uint32_t              m_decProcessingType;    //!<Decode Processing type
    CodechalSetting      *m_codechalSettings = nullptr;    //!<Codechal Settings
    static const uint32_t m_decDefaultMaxWidth = 4096;
    static const uint32_t m_decDefaultMaxHeight = 4096;

#ifdef _DECODE_PROCESSING_SUPPORTED
    bool                           m_requireInputRegion = false;
    VAProcPipelineParameterBuffer *m_procBuf = nullptr; //!< Process parameters for vp sfc input
#endif
MEDIA_CLASS_DEFINE_END(DdiDecodeBase)
};

//} // namespace decode
#endif /*  _DDI_DECODE_BASE_SPECIFIC_H_ */
