/*
* Copyright (c) 2020-2022, Intel Corporation
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
//! \file     null_hardware_next.cpp
//! \brief    Defines interfaces for null hardware
#include "mos_os_mock_adaptor.h"
#include "null_hardware.h"
#include "mhw_mi.h"
#include "mhw_mi_itf.h"

bool  NullHW::m_initilized = false;
bool  NullHW::m_enabled = false;

MOS_STATUS NullHW::Init(
    MOS_CONTEXT_HANDLE osContext)
{
    MOS_STATUS eStatus = MOS_STATUS_SUCCESS;
    if (!m_initilized) {
        m_initilized = true;

        eStatus = MosMockAdaptor::Init(osContext, m_enabled);
        if (eStatus != MOS_STATUS_SUCCESS)
        {
            return eStatus;
        }
    }
    return eStatus;
}

MOS_STATUS NullHW::Destroy()
{
    return MosMockAdaptor::Destroy();
}

MOS_STATUS NullHW::StartPredicateNext(std::shared_ptr<void> pMiItf, PMOS_COMMAND_BUFFER cmdBuffer)
{
    if (!m_enabled)
    {
        return MOS_STATUS_SUCCESS;
    }

    std::shared_ptr<mhw::mi::Itf> miItf = std::static_pointer_cast<mhw::mi::Itf>(pMiItf);
    MOS_OS_CHK_NULL_RETURN(miItf);
    MOS_OS_CHK_NULL_RETURN(cmdBuffer);

    auto &par           = miItf->MHW_GETPAR_F(MI_SET_PREDICATE)();
    par                 = {};
    par.PredicateEnable = MHW_MI_SET_PREDICATE_ENABLE_ALWAYS;
    return miItf->MHW_ADDCMD_F(MI_SET_PREDICATE)(cmdBuffer);
}

MOS_STATUS NullHW::StopPredicateNext(std::shared_ptr<void> pMiItf, PMOS_COMMAND_BUFFER cmdBuffer)
{
    if (!m_enabled)
    {
        return MOS_STATUS_SUCCESS;
    }

    std::shared_ptr<mhw::mi::Itf> miItf = std::static_pointer_cast<mhw::mi::Itf>(pMiItf);
    MOS_OS_CHK_NULL_RETURN(miItf);
    MOS_OS_CHK_NULL_RETURN(cmdBuffer);

    auto &par           = miItf->MHW_GETPAR_F(MI_SET_PREDICATE)();
    par                 = {};
    par.PredicateEnable = MHW_MI_SET_PREDICATE_DISABLE;
    return miItf->MHW_ADDCMD_F(MI_SET_PREDICATE)(cmdBuffer);
}

void NullHW::StatusReport(uint32_t &status, uint32_t &streamSize)
{
    if (!m_enabled)
    {
        return;
    }

    status = 0;
    streamSize = 1024;
}